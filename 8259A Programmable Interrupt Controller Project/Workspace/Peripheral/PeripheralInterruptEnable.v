module PeripheralInterruptEnable (
  input clk,           // Clock input
  input enable_pie,    // Enable signal for Peripheral Interrupt Enable
  input pif,           // Peripheral Interrupt Flag
  output reg pie       // Peripheral Interrupt Enable
);

  always @(posedge clk) begin
    if (enable_pie) begin
        // Enable PIE when requested and when PIF is set
        if (pif) begin
          pie <= 1;
        end
      else begin
        // Disable PIE
        pie <= 0;
      end
    end
  end

endmodule
