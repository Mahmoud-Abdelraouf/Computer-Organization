module GlobalInterruptEnable (
  input clk,           // Clock input
  input enable_gie,    // Enable signal for General Interrupt Enable
  output reg gie       // General Interrupt Enable
);

  always @(posedge clk) begin
    if (enable_gie) begin
      // Enable GIE
      gie <= 1;
    end else begin
      // Disable GIE
      gie <= 0;
    end
  end

endmodule
