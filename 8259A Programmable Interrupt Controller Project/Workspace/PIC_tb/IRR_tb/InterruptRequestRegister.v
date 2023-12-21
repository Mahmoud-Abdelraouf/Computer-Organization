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
    output reg [7:0] risedBits,        // Output: Rised bits indicating valid interrupts.
    output reg [7:0] dataBuffer        // Output: Buffer for interrupts reset by resetIRR.
);

    // Internal register to hold the current state of interrupts
    reg [7:0] interruptState;

    // Logic to handle valid interrupts and reset based on readPriority and resetIRR signals
    always @(*) begin
        // Combine interrupt requests with mask bits to find valid interrupts
        // Valid interrupts have a '0' in bitToMask corresponding to '1' in IR signals
        interruptState = IR0_to_IR7 & ~bitToMask;

        // Resetting interrupts based on readPriority and resetIRR signals
        if (readPriority) begin
            // Reset corresponding interrupts in IRR based on priority resolution and resetIRR value
            if (resetIRR != 0) begin
                interruptState = interruptState & ~(1 << resetIRR);
            end else begin
                interruptState[0] = 0; // Reset IR0 when resetIRR is '0'
            end
        end
    end

    // Storing interrupts in dataBuffer when readIRR is asserted
    always @(*) begin
        if (readIRR) begin
            dataBuffer = interruptState;
        end
    end

    // Logic to output valid interrupts when readIRR is asserted or when there's a change in interruptState
    always @(*) begin
        if (readIRR || (interruptState != risedBits)) begin
            risedBits = interruptState;
        end else begin
            risedBits = 8'bZ; // Preserve previous risedBits if there are no changes or if readIRR is inactive
        end
    end

endmodule
