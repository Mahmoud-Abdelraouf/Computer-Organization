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
    input resetIRR,                    // Input: Signal from priority resolver to reset serviced interrupts.
    output reg [7:0] risedBits         // Output: Rised bits indicating valid interrupts.
);

    // Internal register to hold the state of interrupts
    reg [7:0] interruptState;

    // Logic to handle valid interrupts
    always @* begin
        // Combine interrupt requests with mask bits to find valid interrupts
        // Valid interrupts have a '0' in bitToMask corresponding to '1' in IR signals
        interruptState = IR0_to_IR7 & ~bitToMask;

        // Logic to reset serviced interrupts based on readPriority and resetIRR signals
        if (readPriority && resetIRR) begin
            // Reset corresponding interrupts in IRR based on priority resolution
            interruptState = interruptState & ~readPriority;
        end
    end

    // Logic to output valid interrupts when readIRR is asserted
    always @* begin
        if (readIRR) begin
            risedBits = interruptState;
        end else begin
            risedBits = 8'b0; // Output '0' when not reading the IRR
        end
    end

endmodule
