
/*
   ReadWriteLogic Module

   This Verilog module represents a basic control logic for handling read and write operations
   with associated control signals. It includes outputs for various command words related to
   interrupt controller configuration.

   Module Ports:
   - Input Ports:
     - Read: Read control signal.
     - Write: Write control signal.
     - A0: Address bit 0.
     - CS: Chip Select control signal.
     - Data: 8-bit data input.

   - Output Ports:
     - ICW1: Initialization Command Word 1 (8 bits).
     - ICW2: Initialization Command Word 2 (8 bits).
     - ICW3: Initialization Command Word 3 (8 bits).
     - ICW4: Initialization Command Word 4 (8 bits).
     - OCW1: Operation Command Word 1 (8 bits).
     - OCW2: Operation Command Word 2 (8 bits).
     - OCW3: Operation Command Word 3 (8 bits).
     - read_cmd_to_ctrl_logic : command signal for control logic to tell it to active read status from IRR 
       OR ISR registers 

   Module Behavior:
   - The module is sensitive to the falling edge of the Write control signal.
   - When CS is low, the module performs specific operations based on the control signals.
   - The actual logic for ICWs, OCWs, and other operations are implemented inside the module.

   Usage:
   - Instantiate this module in your design, connecting the required signals.
   
   Author: Ahmed Khaled Abdelmaksod Ebrahim
   Date: 21 DEC 2023
*/

module ReadWriteLogic(
    input Read,
    input write,
    input A0,
    input CS,
    input [7:0]dataBuffer,
    input write_flag_ACK,
    input OCW3_change_ACK,

    output reg write_flag, // done
    output reg [7:0]ICW1,
    output reg [7:0]ICW2,
    output reg [7:0]ICW3,
    output reg [7:0]ICW4,
    output reg [7:0]OCW1,
    output reg [7:0]OCW2,
    output reg [7:0]OCW3,
    output reg read_cmd_to_ctrl_logic,
    output reg read_cmd_imr_to_ctrl_logic,
    output reg OCW3_change
    
);
reg flag = 0;
reg [2:0]counter = 1;
reg temp=0;

/*
    ICW1 -> A0 -> 0 $ D0 -> 1
    ICW2 -> A0 -> 1
	ICW3 -> ICW1[1] = 0

    OSW1 -> A0 -> 1
    OSW2 -> A0 -> 0    D4 -> 0 $ D3 -> 0
    OSW3 -> A0 -> 0    D4 -> 0 $ D3 -> 1
*/
always @(negedge write) begin

    write_flag <= 1'b1;
    if(CS == 1'b0)
    begin
        if(flag == 0 && A0 == 0 && counter == 1&&temp==0)
        begin
            ICW1 = dataBuffer;
            counter= counter +1;
			flag=0;
			temp=1;
        end
        if(flag == 0 && A0 == 1 && counter == 2&&temp==0)
        begin
            ICW2 = dataBuffer;
            counter = counter + 1;
            if(ICW1[1] == 1 && ICW1[0] == 0)
            begin
                flag = 1;
            end
            else
            begin
                flag = 0;
            end
			if((ICW1[1] == 1) && (ICW1[0] == 1))
			begin
				counter = 4;
			end
			temp=1;
        end
        if((counter == 3)&&(flag == 0)&&temp==0)
        begin
            ICW3 = dataBuffer;
            counter = counter + 1;
            if(ICW1[0] == 1)
            begin
                flag = 0;
            end
            else
            begin
                flag = 1;
            end
			temp=1;
        end
        
        if((ICW1[0] == 1) &&( counter == 4)&&(flag == 0)&&(A0 == 1)&&temp==0)
        begin
            ICW4 = dataBuffer;
            counter = counter + 1;
            flag = 1;
			temp=1;
        end
        if((A0 == 1) && (flag == 1)&&temp==0)
        begin
            OCW1 = dataBuffer;
			temp=1;
        end
        
        if(A0 == 0 && dataBuffer[4] == 0 && dataBuffer[3] == 0 && flag == 1&&temp==0)
        begin
            OCW2 = dataBuffer;
			temp=1;
        end

        if(A0 == 0 && dataBuffer[4] == 0 && dataBuffer[3] == 1 && flag == 1&&temp==0)
        begin
            OCW3 = dataBuffer;
        end
		temp = 0;
    end
end
// RD -> 0 && A0 -> 1 // read imr
always @(negedge Read)
begin
    if(CS == 0)
    begin
        if(A0 == 1'b0)
        begin
            read_cmd_to_ctrl_logic <= 1'b1;
            read_cmd_imr_to_ctrl_logic <= 1'b0;
        end
        else
        begin
            read_cmd_to_ctrl_logic <= 1'b0;
            read_cmd_imr_to_ctrl_logic <= 1'b1;
        end
    end
end
always @(posedge Read)
begin
    if(CS == 0)
    begin
        read_cmd_to_ctrl_logic <= 1'b0;
        read_cmd_imr_to_ctrl_logic <= 1'b0;
    end
end

always@(write_flag_ACK)
begin
    write_flag <= 1'b0;
end
always @(OCW3) begin
    OCW3_change <=1'b1;
end
always@(OCW3_change_ACK)begin
    OCW3_change <= 1'b0;
end
endmodule
