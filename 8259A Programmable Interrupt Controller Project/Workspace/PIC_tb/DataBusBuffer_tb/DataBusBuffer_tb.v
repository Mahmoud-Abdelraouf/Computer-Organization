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
  
  // Assign data_in and data_out
  assign data_in = (rd) ? 8'bZ : output_from_inside;
  assign data_out = (wr) ? 8'bZ : input_from_outside;
  
  // Simulation end condition
  initial begin
    // Initialize signals
    rd = 1;
    wr = 1;
    
    // Test Read Operation
    #100;  // Wait for 100 time units
    output_from_inside = 8'h66;
    rd = 0;  // Activate read
    #100;  // Wait for 100 time units
    rd = 1;  // Deactivate read


    // Test Write Operation
    #100;  // Wait for 100 time units
    input_from_outside = 8'h55;
    wr = 0;  // Activate write
    // Set data_in if needed
    #100;  // Wait for 100 time units
    wr = 1;  // Deactivate write

    // End simulation
    #100;  // Wait for 100 time units
    $finish;
  end

endmodule

