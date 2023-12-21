/**
 * @file irr_tb.v
 * @brief Testbench for the Interrupt Request Register (IRR) module
 */

//`timescale 1ns/1ps // Define timescale for simulation accuracy

/**
 * @brief Testbench for the Interrupt Request Register (IRR) module
 * @details Simulates various scenarios to verify the functionality of the InterruptRequestRegister module.
 */
module InterruptRequestRegister_tb;

    // Inputs
    reg [7:0] IR0_to_IR7;      // Input: Interrupt requests from IR0 to IR7.
    reg [7:0] bitToMask;       // Input: Masking bits from IMR for corresponding IRs.
    reg readPriority;          // Input: Read priority signal from control logic.
    reg readIRR;               // Input: Signal to output IRR values to data buffer.
    reg [2:0] resetIRR;        // Input: Signal from priority resolver to reset serviced interrupts.
    
    // Outputs
    wire [7:0] risedBits;      // Output: Rised bits indicating valid interrupts.
    wire [7:0] dataBuffer;     // Output: Buffer for interrupts reset by resetIRR.
    

    // Instantiate the InterruptRequestRegister module
    InterruptRequestRegister irr_inst (
        .IR0_to_IR7(IR0_to_IR7),
        .bitToMask(bitToMask),    
        .readPriority(readPriority),
        .readIRR(readIRR),
        .resetIRR(resetIRR),
        .risedBits(risedBits),
        .dataBuffer(dataBuffer)
    );

    integer num_random_test_cases = 10;
    integer i;

    // Stimulus
    initial begin
        $dumpfile("irr_tb.vcd"); // Define output VCD file
        $dumpvars(0, InterruptRequestRegister_tb); // Dump variables for simulation

        // Test case 1: No interrupts, all masked
        IR0_to_IR7 = $urandom; // Generate random value for IR0_to_IR7
        bitToMask = $urandom; // Generate random value for bitToMask
        readPriority = $urandom_range(0, 1); // Random value for readPriority
        readIRR = $urandom_range(0, 1); // Random value for readIRR
        resetIRR = $urandom_range(0, 7); // Random value for resetIRR
        #10;

        // Test case 2: Simulate interrupts and mask conditions
        IR0_to_IR7 = $urandom; // Generate random value for IR0_to_IR7
        bitToMask = $urandom; // Generate random value for bitToMask
        readPriority = $urandom_range(0, 1); // Random value for readPriority
        readIRR = $urandom_range(0, 1); // Random value for readIRR
        resetIRR = $urandom_range(0, 7); // Random value for resetIRR
        #10;

        for (i = 0; i < num_random_test_cases; i = i + 1) begin
            // Generate random values for inputs
            IR0_to_IR7 = $urandom; // Random value for IR0_to_IR7
            bitToMask = $urandom; // Random value for bitToMask
            readPriority = $urandom_range(0, 1); // Random value for readPriority
            readIRR = $urandom_range(0, 1); // Random value for readIRR
            resetIRR = $urandom_range(0, 7); // Random value for resetIRR

            #10; // Add delay for each test case
        end

        $finish; // End simulation
    end

endmodule

