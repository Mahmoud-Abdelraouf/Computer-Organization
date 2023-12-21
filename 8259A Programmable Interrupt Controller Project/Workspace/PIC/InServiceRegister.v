module InServiceRegister (
  input wire [7:0] interruptState, // Input: Register containing interrupt states
  input wire [2:0] resetISR,       // Input: Signal to reset serviced interrupts
  output reg [7:0] ISR_reg         // Output: Register for servicing interrupts
);

  // Logic to handle storing interrupts to be serviced
  always @* begin
    if (resetISR != 0) begin
      // Reset the corresponding interrupt in the ISR_reg based on resetISR
      ISR_reg[resetISR] = 1'b0;
    end else begin
      // Store interrupts to be serviced based on interruptState
      ISR_reg = interruptState;
    end
  end

endmodule
