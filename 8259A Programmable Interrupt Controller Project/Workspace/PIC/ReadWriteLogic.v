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
    input  [7:0]Data,

    output reg [7:0]ICW1,
    output reg [7:0]ICW2,
    output reg [7:0]ICW3,
    output reg [7:0]ICW4,
    output reg [7:0]OCW1,
    output reg [7:0]OCW2,
    output reg [7:0]OCW3,
    output reg read_cmd_to_ctrl_logic
);
reg flag = 0;
reg counter = 1;

/*
    ICW1 -> A0 -> 0 $ D0 -> 1
    ICW2 -> A0 -> 1

    OSW1 -> A0 -> 1
    OSW2 -> A0 -> 0    D4 -> 0 $ D3 -> 0
    OSW3 -> A0 -> 0    D4 -> 0 $ D3 -> 1
*/
always @(negedge write) begin
    if(CS == 1'b0)
    begin
        if(flag == 0 && A0 == 0)
        begin
            ICW1 <= Data;
            counter= counter +1;
        end
        if(flag == 0 && A0 == 1 && counter == 2)
        begin
            ICW2 <= Data;
            counter = counter + 1;
            if(ICW1[1] == 0 || ICW1[0] == 1)
            begin
                flag = 0;
            end
            else
            begin
                flag = 1;
            end
        end
        if(ICW1[1] == 0 && counter == 3&&flag == 0)
        begin
            ICW3 <= Data;
            counter = counter + 1;
            if(ICW1[0] == 1)
            begin
                flag = 0;
            end
            else
            begin
                flag = 1;
            end
        end
        if(ICW1[0] == 1 && counter == 4&&flag == 0)
        begin
            ICW4 <= Data;
            counter = counter + 1;
            flag = 1;
        end
        if(A0 == 1 && flag == 1)
        begin
            OCW1 <= Data;
        end
        
        if(A0 == 0 && Data[4] == 0 && Data[3] == 0 && flag == 1)
        begin
            OCW2 <= Data;
        end

        if(A0 == 0 && Data[4] == 0 && Data[3] == 1 && flag == 1)
        begin
            OCW3 <= Data;
        end
    end
end

always @(negedge Read) begin
    if(CS == 0)
    begin
        read_cmd_to_ctrl_logic <= 1'b1; 
    end
end

endmodule