/**
 * @file irr.v
 * @brief Interrupt Request Register (IRR) module for interrupt handling
 */

/**
 * @brief Interrupt Request Register (IRR) Module
 * @details Manages the Interrupt Request Register to handle interrupt requests and priority resolution.
 * It interfaces with the Interrupt Mask Register (IMR) and control logic for interrupt servicing.
 */
module InterruptRequestRegister (
    input [7:0] IR0_to_IR7,            // Input: Interrupt requests from IR0 to IR7.
    input [7:0] bitToMask,             // Input: Masking bits from IMR for corresponding IRs.
    input readPriority,                // Input: Read priority signal from control logic.
    input readIRR,                     // Input: Signal to output IRR values to data buffer.
    input [2:0] resetIRR,              // Input: Signal from priority resolver to reset serviced interrupts.
    input [7:0] ICW1,                  // Input: Initialization Command Word 1 with LTIM bit.
    output reg [7:0] risedBits = 8'b0, // Output: Rised bits indicating valid interrupts.
    output reg [7:0] dataBuffer        // Output: Buffer for interrupts reset by resetIRR.
    output reg readPriorityAck = 1'b0, // Output:
);

    // Internal register to hold the current state of interrupts
    reg [7:0] interruptState;

    // Determine operating mode based on ICW1's LTIM bit
    reg levelTriggered;

    // Logic to handle valid interrupts and reset based on readPriority and resetIRR signals
    always @(IR0_to_IR7, bitToMask) begin
        // Combine interrupt requests with mask bits to find valid interrupts
        // Valid interrupts have a '0' in bitToMask corresponding to '1' in IR signals
        interruptState = IR0_to_IR7 & ~bitToMask;
    end

    always @(posedge readPriority) begin
        // Resetting interrupts based on readPriority and resetIRR signals
        // Reset corresponding interrupts in IRR based on priority resolution and resetIRR value
        if (resetIRR != 0) begin
            interruptState = interruptState & ~(1 << resetIRR);
        end else begin
            interruptState[0] = 0; // Reset IR0 when resetIRR is '0'
        end
        readPriorityAck <= ~readPriorityAck;
    end

    // Storing interrupts in dataBuffer when readIRR is asserted
    always @(*) begin
        if (readIRR) begin
            dataBuffer = interruptState;
        end else begin
            dataBuffer = 8'bZ;
        end
    end

    // Update risedBits based on level/edge triggered interrupt mode
    always @(*) begin
        // Assuming LTIM bit is at position 3 in ICW1
        levelTriggered = ICW1[3]; // LTIM bit determines the mode

        // If LTIM = 1, then operate in level interrupt mode.
        // If LTIM = 0, then operate in edge interrupt mode.
        if (levelTriggered == 1) begin
            // Level-triggered mode: The interrupt is considered asserted as long as the signal remains in that state.
            risedBits = interruptState;
        end else begin
            // Edge-triggered mode: The interrupt is signaled at the moment of the transition (rising or falling edge) of the signal.
            // Detect the rising edge to signal the interrupt
            risedBits = interruptState & ~risedBits;
        end
    end

endmodule

