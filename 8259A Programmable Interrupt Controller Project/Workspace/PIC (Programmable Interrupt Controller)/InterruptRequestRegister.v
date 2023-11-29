module InterruptRequestRegister (
  input clk,                   // Clock input
  input [7:0] pif,             // Peripheral Interrupt Flags
  output reg [7:0] irr         // Interrupt Request Register
);

  always @(posedge clk) begin
    // Store interrupt requests in the IRR
    irr <= pif;
  end

endmodule

