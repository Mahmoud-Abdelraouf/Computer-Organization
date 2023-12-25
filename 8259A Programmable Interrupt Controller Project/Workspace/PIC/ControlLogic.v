module ControlLogic(
    input INTA,                             // Input: Interrupt acknowledge from CPU
    input INT_request,                      // Input: Interrupt request from priority resolver
    
    input read_priority_ACK,                // Input: periority ack to deactive the flag read_priority

    input [2:0] interrupt_index,            // Input: ID of interrupt to be handled(come from ISR)
    input send_vector_ISR_ACK,              // Input: acknowledge to deactivate send vector flag

    input read_cmd_to_ctrl_logic,           // Input: Sent from read/write logic to read status of ISR or IRR or priority
    input [7:0] OCW3,                       // Input: Will be used to know which register to read its status 
    input write_flag,                       // Input: to indicate that there are writing operation 
    input [7:0]ICW3,                        // Input: initial word no. 3 for cascading mode
    input read_cmd_imr_to_ctrl_logic,       // Input: Read command to control logic to active IMR to read its state
    input [7:0] ICW1,
    input cascade_flag,                     // Input: In case of slave, it will be sent from cascade in case of desired slave
    input SP,                               // Input: to determined the pic is master or slave
    input cascade_signal_ACK,
    input EOI,

    output reg INT,                         // Output: Interrupt request will be sent to CPU

    output reg read_IRR,                    // Output: Signal to read IRR status ( will be sent to IRR)
    output reg read_priority,               // Output: Is set after the first INTA pulse (will be sent to IRR and ISR)
    
    output reg freezing,                    // Output: Is set between to INTA pulse.
    output reg INT_request_ACK=1'b0,

    output reg read_IMR,                    // Input: to active reading state from imr Register

    output reg send_vector_ISR,             // Output: flag to allow ISR to send its Vector
    output reg read_ISR,                    // Output: Signal to read ISR status ( will be sent to ISR)
    output reg pulse_ACK,                   // Output: Acknowledge will be sent to ISR
    output reg second_ACK=0,                // to determine that second INTA came ( used for ISR )
    
    output reg EOI_to_cascade,
    output reg cascade_signal,              // Output: Signal will be sent to cascade controller to start working
    output reg desired_slave,                // Output: Slave ID that will be sent to cascade controller in case of master
    output reg cascade_flag_ACK=1'b0
);
   // Configurations for read_ISR and read_IRR flags
    localparam read_from_ISR =2'b11;        // Local parameter representing read from ISR mode
    localparam read_from_IRR =2'b01;        // Local parameter representing read from IRR mode
    reg [1:0] read_register;    
    always @(OCW3)begin
        read_register=OCW3[1:0]; 
    end
    
    // Do configurations when recieving signal from read/write logic
    always @(posedge read_cmd_to_ctrl_logic) begin
        // Decide what flag to set based on coming signal 
        case(read_register)
            read_from_ISR: begin
                read_ISR<=1'b1; // set read from ISR flag to send ISR register
                read_IRR<=1'b0; // reset read from IRR flag 
            end
            read_from_IRR: begin
                read_IRR<=1'b1; // set read from IRR flag to send IRR register
                read_ISR<=1'b0; // reset read from ISR flag
            end
            default: begin
                read_IRR<=1'b0; // set read from IRR flag to send IRR register
                read_ISR<=1'b0; // reset read from ISR flag
            end
        endcase 
    end
    
    // deactive flags to stop reading the IRR and ISR Registers
    always @(negedge read_cmd_to_ctrl_logic) begin
        read_ISR<=1'b0;
        read_IRR<=1'b0;
    end

    // block to handle reading from imr register 
    always @(read_cmd_imr_to_ctrl_logic)
    begin
        if(read_cmd_imr_to_ctrl_logic) // read operation active 
        begin
            read_IMR <= 1'b1;
        end
        else // deactive read operation
        begin
            read_IMR <= 1'b0;
        end
    end

    // Configurations for freezing and read_priority flags
    localparam first_INTA=1'b0;         // Local parameter representing first INTA
    localparam second_INTA=1'b1;        // Local parameter representing second INTA
    reg counter=0; //  counter for first and second INTA
    always@(negedge INTA)begin
        // if it's the first INTA set read_priority and freezing flags
        if(counter==first_INTA)begin
            read_priority<=1'b1;
            freezing<=1'b1;
            counter=counter+1;
            second_ACK=0;
        end
        // if it't the second INTA reset read_priority and freezing flags
        else if(counter==second_INTA)begin
            read_priority<=1'b0;
            freezing<=1'b0;
            counter=1'b0;
            second_ACK=1;
        end
    end

    // Handling INT request which will be sent to Processor
    // if there are any reading or writing operations we cann't send any interrupt
    always@(posedge INT_request)
    begin
        if(write_flag == 1'b0 && read_cmd_to_ctrl_logic == 1'b0)
        begin
            INT <= 1'b1;
        end
        INT_request_ACK = ~INT_request_ACK;
    end
    always @(negedge INT_request) begin
        INT <= 1'b0;
    end
    always @(posedge EOI)begin
        EOI_to_cascade=EOI;
        INT=0;
    end

    localparam MASTER=1'b1;
    localparam SLAVE=1'b0;
    always@(posedge second_ACK)
    begin
        if(ICW1[1])begin
            send_vector_ISR=1;
            cascade_signal=0;
            read_ISR=0;
            read_IRR=0;
            read_IMR=0;
        end
        else begin
            if(SP==MASTER)begin
                if(ICW3[interrupt_index])begin
                send_vector_ISR=0;
                cascade_signal=1;
                desired_slave=interrupt_index;
            end
            else begin
                send_vector_ISR=1;
                cascade_signal=0;
                read_ISR=0;
                read_IRR=0;
                read_IMR=0;
            end
            end
            else if(SP==SLAVE)begin
                if(cascade_flag) begin
                    send_vector_ISR=1;
                    read_ISR=0;
                    read_IRR=0;
                    read_IMR=0;
                    cascade_flag_ACK=~cascade_flag_ACK;
                end
                else begin
                    send_vector_ISR=0;
                end
            end       
            end
    end
    always @(cascade_signal_ACK)begin
        cascade_signal=1'b0;
    end
    always @(send_vector_ISR_ACK)begin
        send_vector_ISR=1'b0;
    end

    // Ack of read_priority flag to deactivate it 
    always@(read_priority_ACK)
    begin
        read_priority = 1'b0; 
    end

endmodule
