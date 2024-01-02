module PIC_TopModule_tb;

// Inputs
reg INTA;
reg RD;
reg WR; 
reg A0; 
reg CS; 
wire [3:0] CAS; 
reg SP;
reg [7:0] IR0_to_IR7;

// Outputs
wire INT;
wire [7:0] sys_DataLine;
reg [7:0] sys;

integer i, j, k, l, m, n, o, p;

PIC_TopModule topModuleInstance(
    .INTA(INTA),
    .INT(INT),
    .sys_DataLine(sys_DataLine),
    .RD(RD),
    .WR(WR),
    .A0(A0),
    .CS(CS),
    .CAS(CAS),
    .SP(SP),
    .IR0_to_IR7(IR0_to_IR7)
);

assign sys_DataLine = sys;

initial begin
    // initialize inputs
    INTA = 1; 
    RD = 1;
    WR = 1;
    A0 = 0;
    CS = 1;
    SP = 1;
    IR0_to_IR7 = 8'b00000000;
    sys = 8'b00000000;
    #10

    // Apply Stimulus
    
  // Single Mode -NO ICW4- Edge Triggered
    // ICW1 
    RD = 1;
    WR = 1;
    A0 = 0;
    CS = 1;
    SP = 1;
    IR0_to_IR7 = 8'b00000000;
    sys = 8'b00110110;
    #10

    // ICW1
    RD = 1;
    WR = 0;
    A0 = 0;
    CS = 1;
    SP = 1;
    IR0_to_IR7 = 8'b00000000;
    sys = 8'b00110110;
    #10

    // ICW2
    RD = 1;
    WR = 1;
    A0 = 0;
    CS = 0;
    SP = 1;
    IR0_to_IR7 = 8'b00000000;
    sys = 8'b11111111;
    #10

    // ICW2
    RD = 1;
    WR = 0;
    A0 = 0;
    CS = 0;
    SP = 1;
    IR0_to_IR7 = 8'b00000000;
    sys = 8'b11111111;
    #10

    // Receive first interrupt IR0
    RD = 1;
    WR = 1;
    A0 = 0;
    CS = 0;
    SP = 1;
    IR0_to_IR7 = 8'b10000000;
    sys = 8'bzzzzzzzz;
    #10


    INTA = 0;
    #1

    INTA = 1;
    #10

    
    INTA = 0;
    #1

    INTA = 1;
    #10

    
    INTA = 0;
    RD = 0;
    #1

    INTA = 1;
    #10

    $stop; // End Simulation
end

endmodule //PIC_TopModule_tb
