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
    reg [7:0] IR0_to_IR7;      // Input: Interrupt requests from IR0 to IR7.
    reg readPriority;          // Input: Read priority signal from control logic.
    reg readIRR;               // Input: Signal to output IRR values to data buffer.
    reg [2:0] resetIRR;        // Input: Signal from priority resolver to reset serviced interrupts.
    reg [7:0] OCW1;            // Input: Some signal from IMR module
    reg writeIMR;              // Input: Another signal from IMR module

    // Outputs
    wire [7:0] risedBits;      // Output: Rised bits indicating valid interrupts.
    wire [7:0] dataBuffer;     // Output: Buffer for interrupts reset by resetIRR.
    wire [7:0] bitToMask;      // Output: Masking bits from IMR for corresponding IRs.

    // Instantiate the IMR module
    IMR imr_inst (
        .OCW1(OCW1),                  // Connect OCW1 to a random value in the testbench
        .writeIMR(writeIMR),          // Connect writeIMR to a random value in the testbench
        .bitToMask(bitToMask),        // Connect bitToMask to the IMR's bitToMask output
        .dataBuffer(dataBuffer)       // Connect dataBuffer to the IMR's dataBuffer output
    );

    // Instantiate the InterruptRequestRegister module
    InterruptRequestRegister irr_inst (
        .IR0_to_IR7(IR0_to_IR7),
        .bitToMask(bitToMask),        // Connect bitToMask from the IMR module to the IRR module
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
        IR0_to_IR7 = $urandom; // Generate random value for IR0_to_IR7
        bitToMask = 8'b11111111;
        readPriority = $urandom_range(0, 1); // Random value for readPriority
        readIRR = $urandom_range(0, 1); // Random value for readIRR
        resetIRR = $urandom_range(0, 7); // Random value for resetIRR
        writeIMR = $urandom_range(0, 1); // Random value for writeIMR
        #10;

        // Test case 2: Simulate interrupts and mask conditions
        IR0_to_IR7 = $urandom; // Generate random value for IR0_to_IR7
        bitToMask = 8'b11001100;
        readPriority = $urandom_range(0, 1); // Random value for readPriority
        readIRR = $urandom_range(0, 1); // Random value for readIRR
        resetIRR = $urandom_range(0, 7); // Random value for resetIRR
        writeIMR = $urandom_range(0, 1); // Random value for writeIMR
        #10;

        integer num_random_test_cases = 10;
        integer i;
        for (i = 0; i < num_random_test_cases; i = i + 1) begin
            // Generate random values for inputs
            IR0_to_IR7 = $urandom; // Random value for IR0_to_IR7
            bitToMask = $urandom; // Random value for bitToMask
            readPriority = $urandom_range(0, 1); // Random value for readPriority
            readIRR = $urandom_range(0, 1); // Random value for readIRR
            resetIRR = $urandom_range(0, 7); // Random value for resetIRR
            writeIMR = $urandom_range(0, 1); // Random value for writeIMR

            // Prevent writeIMR and readIRR from being active simultaneously
            if (writeIMR && readIRR) begin
                writeIMR = 0; // Deactivate writeIMR
            end

            #10; // Add delay for each test case
        end

        $finish; // End simulation
    end


endmodule
