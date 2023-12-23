`timescale 1ns/1ps
module ReadWriteLogic_tb;
    reg Read;
    reg write;
    reg A0;
    reg CS;
    reg [7:0]dataBuffer;
    reg write_flag_ACK;

    wire write_flag; // done
    wire [7:0]ICW1;
    wire [7:0]ICW2;
    wire [7:0]ICW3;
    wire [7:0]ICW4;
    wire [7:0]OCW1;
    wire [7:0]OCW2;
    wire [7:0]OCW3;
    wire read_cmd_to_ctrl_logic;

    ReadWriteLogic RW(.Read(Read),.write(write),.A0(A0),.CS(CS),.dataBuffer(dataBuffer),.write_flag_ACK(write_flag_ACK),
    .write_flag(write_flag),.ICW1(ICW1),.ICW2(ICW2),.ICW3(ICW3),.ICW4(ICW4),.OCW1(OCW1),.OCW2(OCW2),.OCW3(OCW3),
    .read_cmd_to_ctrl_logic(read_cmd_to_ctrl_logic));

    initial begin
        write = 1;
        CS =0;
        A0 = 0;
        Read = 1;
        dataBuffer = 8'b00010001;
        #100;
        write = 0;
        CS =0;
        A0 = 0;
        Read = 1;
        dataBuffer = 8'b00010001;
        #100;
        write = 1;
        CS =0;
        A0 = 1;
        Read = 1;
        dataBuffer = 8'b00010111;
        #100;
        write = 0;
        CS =0;
        A0 = 1;
        Read = 1;
        dataBuffer = 8'b00010111;
        #100;
        write = 1;
        CS =0;
        A0 = 1;
        Read = 1;
        dataBuffer = 8'b01010101;
        
        #100;
        write = 0;
        CS =0;
        A0 = 1;
        Read = 1;
        dataBuffer = 8'b01010101;

        
        #100;
        write = 1;
        CS =0;
        A0 = 1;
        Read = 1;
        dataBuffer = 8'b10001111;

        #100;
        write = 0;
        CS =0;
        A0 = 1;
        Read = 1;
        dataBuffer = 8'b10001111;
    end
endmodule
