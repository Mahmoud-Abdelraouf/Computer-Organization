/**
 * @file cascade_controller.v
 * @brief Cascading Controller Module for Interrupt Handling
 */

/**
 * @brief Cascade Controller Module
 * This module manages the cascading functionality for interrupt handling within a microcontroller.
 * It interfaces with slave devices based on priority pins and manages the transmission of interrupt vectors.
 *
 * @details
 * The cascade_controller module operates in two modes: SLAVE and MASTER.
 * In SLAVE mode, the module receives an 8-bit configuration signal (ICW3) and extracts the first 3 bits to compute a unique slave ID. 
 * In MASTER mode, it controls the cascade control lines (CAS) based on the desired slave ID received from control logic.
 *
 * The module monitors a control signal to trigger actions on the rising edge.
 * In SLAVE mode, it compares the computed slave ID with the current value of CAS and sets a flag accordingly. 
 * In MASTER mode, it updates the CAS lines to the desired slave.
 *
 */
module CascadeController(
    inout [2:0] CAS,             // Input/Output: Cascade control lines.
    input SP,                    // Input: Selects between MASTER and SLAVE modes.
    input [7:0] ICW3,            // Input: ICW3 signal, used for configuration.
    input control_signal,        // Input: Signal that comes from control logic.
    input [2:0] desired_slave,   // Input: Desired slave ID in case of MASTER mode.
    output reg flag              // Output: Flag indicating if it's the desired slave.
    output reg SP_to_control     // Output: Send SP to control logic
);
    localparam SLAVE = 1'b0;     // Local parameter representing the SLAVE mode.
    localparam MASTER = 1'b1;    // Local parameter representing the MASTER mode.
    
    reg [2:0] ID;                // reg to hold ID of the slave
    reg [2:0] temp_cas;          // reg to save the value of cas in always block
    assign CAS=temp_cas;         // assign value of cascade lines in master mode 
    // get ID of the slave from ICW3 
    always @(*) begin
        if (SP == SLAVE) begin
            ID = ICW3[2:0]; // Compute ID for SLAVE mode
        end
    end
    // configurations of the cascade controller when receiving control signal based on mode (slave or master)
    always @(posedge control_signal) begin
        case (SP)
            // in case of slave mode : check if the cascade lines equals the slave ID
            SLAVE: begin
                if (ID == CAS) begin
                    flag <= 1'b1; // Set flag to 1 if it's the desired slave
                end
                else begin
                    flag <= 1'b0; // Reset flag if it's not the desired slave
                end
            end
            // in case of master mode: assign the desired slave id to temp_cas which will update cascade lines
            MASTER: begin
                temp_cas = desired_slave; // Set CAS to the desired slave ID in MASTER mode
            end
        endcase
    end
    always @(SP) begin
        SP_to_control<=SP;
    end
endmodule
