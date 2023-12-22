module InServiceRegister_tb;

  // Inputs
  reg [2:0] toSet;
  reg readPriority, readIsr, sendVector;
  reg [2:0] zeroLevelIndex;
  reg [7:0] ICW2, ICW4, OCW2;
  reg secondACK, changeInOCW2;

  // Outputs
  wire [2:0] INTIndex;
  wire [7:0] dataBuffer, isrRegValue;
  wire [2:0] resetedIndex;

  // Instantiate the module
  InServiceRegister dut (
    .toSet(toSet),
    .readPriority(readPriority),
    .readIsr(readIsr),
    .sendVector(sendVector),
    .zeroLevelIndex(zeroLevelIndex),
    .ICW2(ICW2),
    .ICW4(ICW4),
    .secondACK(secondACK),
    .changeInOCW2(changeInOCW2),
    .INTIndex(INTIndex),
    .dataBuffer(dataBuffer),
    .isrRegValue(isrRegValue),
    .resetedIndex(resetedIndex)
  );

  // Clock
  reg clk = 0;

  // Clock generation
  always #5 clk = ~clk;

  // Test scenario
  initial begin
    // Initialize inputs
    toSet = 3'b001;
    readPriority = 1'b0;
    readIsr = 1'b0;
    sendVector = 1'b0;
    zeroLevelIndex = 3'b101;
    ICW2 = 8'b10101010;
    ICW4 = 8'b11001100;
    secondACK = 1'b0;
    changeInOCW2 = 1'b0;
    OCW2 = 8'b00110011;

    // Apply inputs
    #10 readPriority = 1'b1;
    #10 readIsr = 1'b1;
    #10 sendVector = 1'b1;
    #10 secondACK = 1'b1;
    #10 changeInOCW2 = 1'b1;

    // Simulate some clock cycles
    #100 $finish;
  end

  // Monitor
  always @(posedge clk) begin
    // Display outputs
    $display("Time=%0t, INTIndex=%b, dataBuffer=%b, isrRegValue=%b, resetedIndex=%b", $time, INTIndex, dataBuffer, isrRegValue, resetedIndex);
  end

endmodule
