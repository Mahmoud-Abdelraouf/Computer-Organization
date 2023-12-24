module DataBusBuffer_tb;

  reg rd, wr;
  wire [7:0] data_in, data_out;

  // Instantiate the Main module
  DataBusBuffer dataBusBuffer (
    .data_inside(data_in),
    .data_outside(data_out),
    .rd(rd),
    .wr(wr)
  );
  
  reg [7:0] input_from_outside;
  reg [7:0] output_from_inside;
  
  always @(negedge wr) begin
    // Check if wr is active low
    input_from_outside <= 8'hAB;  // Example data for testing
  end

  always @(negedge rd) begin
    // Check if rd is active low
    output_from_inside <= 8'hCD;  // Example data for testing
  end
  
  // Simulation end condition
  initial begin
    // Initialize signals
    rd = 1;
    wr = 1;
    
    // Test Read Operation
    #10;  // Wait for 10 time units
    rd = 0;  // Activate read
    #10;  // Wait for 10 time units
    rd = 1;  // Deactivate read

    // Test Write Operation
    #10;  // Wait for 10 time units
    wr = 0;  // Activate write
    // Set data_in if needed
    #10;  // Wait for 10 time units
    wr = 1;  // Deactivate write

    // End simulation
    #10;  // Wait for 10 time units
    $finish;
  end

endmodule
