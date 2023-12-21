/**
 * @file irr_tb.v
 * @brief Testbench for the Interrupt Request Register (IRR) module
 */

`timescale 1ns/1ps // Define timescale for simulation accuracy

/**
 * @brief Testbench for the Interrupt Request Register (IRR) module
 * @details Simulates various scenarios to verify the functionality of the InterruptRequestRegister module.
 */
module InterruptRequestRegister_tb;

    // Inputs
    reg [7:0] IR0_to_IR7;   // Input: Interrupt requests from IR0 to IR7.
    reg [7:0] bitToMask;    // Input: Masking bits from IMR for corresponding IRs.
    reg readPriority;       // Input: Read priority signal from control logic.
    reg readIRR;            // Input: Signal to output IRR values to data buffer.
    reg [2:0] resetIRR;     // Input: Signal from priority resolver to reset serviced interrupts.

    // Outputs
    wire [7:0] risedBits;   // Output: Rised bits indicating valid interrupts.
    wire [7:0] dataBuffer;  // Output: Buffer for interrupts reset by resetIRR.

    // Instantiate the module
    InterruptRequestRegister dut (
        .IR0_to_IR7(IR0_to_IR7),
        .bitToMask(bitToMask),
        .readPriority(readPriority),
        .readIRR(readIRR),
        .resetIRR(resetIRR),
        .risedBits(risedBits),
        .dataBuffer(dataBuffer)
    );

    // Stimulus
    initial begin
        $dumpfile("irr_tb.vcd"); // Define output VCD file
        $dumpvars(0, InterruptRequestRegister_tb); // Dump variables for simulation

        // Test case 1: No interrupts, all masked
        IR0_to_IR7 = 8'b00000000;
        bitToMask = 8'b11111111;
        readPriority = 1'b0;
        readIRR = 1'b0;
        resetIRR = 3'b000;
        #10;

        // Test case 2: Simulate interrupts and mask conditions
        IR0_to_IR7 = 8'b10101010;
        bitToMask = 8'b11001100;
        readPriority = 1'b1;
        readIRR = 1'b1;
        resetIRR = 3'b001;
        #10;

        integer num_random_test_cases = 10;
        integer i;
        for (i = 0; i < num_random_test_cases; i = i + 1) begin
            // Generate random values for inputs
            IR0_to_IR7 = $random;
            bitToMask = $random;
            readPriority = $urandom_range(0, 1);
            readIRR = $urandom_range(0, 1);
            resetIRR = $urandom_range(0, 7);

            #10; // Add delay for each test case
        end

        $finish; // End simulation
    end

endmodule
