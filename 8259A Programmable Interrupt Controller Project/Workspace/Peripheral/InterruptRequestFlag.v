module InterruptRequestFlag (
  input clk,                   // Clock input
  input [7:0] event_condition, // Conditions indicating events from the peripherals
  input enable_pie,            // Enable signal for Peripheral Interrupt Enable
  input enable_gie,            // Enable signal for General Interrupt Enable
  output reg interrupt         // Final interrupt signal
);

  reg [7:0] pif;       // Peripheral Interrupt Flags
  reg pie;             // Peripheral Interrupt Enable
  reg gie;             // General Interrupt Enable

  // Peripheral module to generate PIF signals for 8 peripherals
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : periph_instances
      PeripheralInterruptFlag peripheral_interrupt_flag_inst (
        .clk(clk),
        .event_condition(event_condition[i]),
        .enable_pie(enable_pie),
        .pif(pif[i])
      );
    end
  endgenerate

  // PeripheralController module to manage PIE signal
  PeripheralInterruptEnable peripheral_controller_inst (
    .clk(clk),
    .enable_pie(enable_pie),
    .pif(pif[0]), // For example, using peripheral 0 for enabling PIE
    .pie(pie)
  );

  // InterruptController module to manage GIE signal
  GlobalInterruptEnable general_interrupt_enable_inst (
    .clk(clk),
    .enable_gie(enable_gie),
    .pie(pie),
    .gie(gie)
  );

  // Combined logic to generate interrupt when all conditions are met
  always @(posedge clk) begin
    if (enable_gie) begin
      if (|pif && pie && gie) begin
        interrupt <= 1;
      end else begin
        interrupt <= 0;
      end
    end else begin
      interrupt <= 0;
    end
  end

endmodule