module PriorityResolver (
  input clk,                   // Clock input
  input [7:0] irr,             // Interrupt Request Register
  output reg interrupt_service // Interrupt service signal
);

  reg [2:0] highest_priority;  // Stores the index of the highest priority interrupt

  always @(posedge clk) begin
    // Priority resolution logic
    case(irr)
      8'b00000001: highest_priority <= 3'b000; // Highest priority is peripheral 0
      8'b00000010: highest_priority <= 3'b001; // Priority is peripheral 1
      8'b00000100: highest_priority <= 3'b010; // Priority is peripheral 2
      8'b00001000: highest_priority <= 3'b011; // Priority is peripheral 3
      8'b00010000: highest_priority <= 3'b100; // Priority is peripheral 4
      8'b00100000: highest_priority <= 3'b101; // Priority is peripheral 5
      8'b01000000: highest_priority <= 3'b110; // Priority is peripheral 6
      8'b10000000: highest_priority <= 3'b111; // Lowest priority is peripheral 7
      default: highest_priority <= 3'b111; // Default: Lowest priority is peripheral 7
    endcase

    // Service the highest priority interrupt
    if (irr != 8'b00000000) begin
      interrupt_service <= 1;  // Signal interrupt service
      // Simulate serving the interrupt (clear the IRR for the serviced interrupt)
      irr[highest_priority] <= 0; // Clear the interrupt request for the serviced interrupt
    end else begin
      interrupt_service <= 0;  // No interrupts to service
    end
  end

endmodule
