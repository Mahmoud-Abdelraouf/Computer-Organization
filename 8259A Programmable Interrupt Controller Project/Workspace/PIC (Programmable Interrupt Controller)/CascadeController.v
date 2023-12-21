/**
 * @file cascade_controller.v
 * @brief Cascading Controller Module for Interrupt Handling
 */

/**
 * @brief Cascade Controller Module
 * This module manages the cascading functionality for interrupt handling within a microcontroller.
 * It interfaces with slave devices based on priority pins and manages the transmission of interrupt vectors.
 */
module cascade_controller(
    inout [2:0] CAS,             // Input/Output: Cascade control lines.
    input SP,                    // Input: Selects between MASTER and SLAVE modes.
    input [7:0] ICW3,            // Input: ICW3 signal, used for configuration.
    input control_signal,        // Input: Signal that comes from control logic.
    input [2:0] desired_slave;   // Input: Desired slave ID in case of MASTER mode.
    output reg flag              // Output: Flag indicating if it's the desired slave.
);
    localparam SLAVE = 1'b0;     // Local parameter representing the SLAVE mode.
    localparam MASTER = 1'b1;    // Local parameter representing the MASTER mode.
    
    reg [2:0] ID;                // Reg to hold ID of the slave
    
    always @(*) begin
        if (SP == SLAVE) begin
            ID = ICW3 | 3'b111; // Compute ID for SLAVE mode
        end
    end

    always @(posedge control_signal ) begin
        case (SP):
            SLAVE: begin
                if (ID == CAS) begin
                    flag <= 1'b1; // Set flag to 1 if it's the desired slave
                end
                else begin
                    flag <= 1'b0; // Reset flag if it's not the desired slave
                end
            end
            MASTER: begin
                CAS <= desired_slave; // Set CAS to the desired slave ID in MASTER mode
            end
        endcase
    end
endmodule
