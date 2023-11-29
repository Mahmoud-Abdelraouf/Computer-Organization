module Peripheral (
  input clk,             // Clock input
  input event_condition, // Condition indicating an event from the peripheral
  output reg pif         // Peripheral Interrupt Flag
);

always @(posedge clk) begin
  // Check for conditions that generate interrupts
  if (event_condition) begin
    // Set PIF when an event occurs
    pif <= 1;
  end
end

endmodule
