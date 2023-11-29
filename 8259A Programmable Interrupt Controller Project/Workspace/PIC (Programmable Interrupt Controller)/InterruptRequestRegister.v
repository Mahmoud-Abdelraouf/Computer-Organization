module InterruptRequestRegister (
  input clk,                             // Clock input
  input [7:0] event_condition,           // Conditions indicating events from the peripherals
  input [7:0] enable_pie,                // Enable signal for Peripheral Interrupt Enable
  input enable_gie,                      // Enable signal for General Interrupt Enable
  output reg interrupt,                  // Final interrupt signal
  output reg [7:0] valid_interrupts,     // Latch to store indices of valid interrupts
  output reg [7:0] imr                   // Interrupt Mask Register
);

  reg [7:0] pif;                         // Peripheral Interrupt Flags
  reg [7:0] pie;                         // Peripheral Interrupt Enable
  reg gie;                               // General Interrupt Enable
  reg [7:0] irr;                         // Interrupt Request Register
  reg [7:0] isr;                         // In-Service Register

  // Latch to store the indices of valid interrupts
  reg [7:0] valid_interrupts_latch;

  // Initialize IMR to zero
  initial begin
    imr = 8'b0;
  end

  // Peripheral module to generate PIF signals for 8 peripherals
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : periph_instances
      PeripheralInterruptFlag peripheral_interrupt_flag_inst (
        .clk(clk),
        .event_condition(event_condition[i]),
        .pif(pif[i])
      );
    end
  endgenerate

  // PeripheralController module to manage PIE signal for all peripherals
  generate
    for (i = 0; i < 8; i = i + 1) begin : periph_controller_instances
      PeripheralInterruptEnable peripheral_controller_inst (
        .clk(clk),
        .enable_pie(enable_pie[i]),
        .pie(pie[i])
      );
    end
  endgenerate

  // InterruptController module to manage GIE signal
  GlobalInterruptEnable general_interrupt_enable_inst (
    .clk(clk),
    .enable_gie(enable_gie),
    .gie(gie)
  );

  // Priority Resolver
  always @(*) begin
    case(pif)
      // Define priorities based on the peripheral interrupt flags
      // Adjust priorities as per the system's priority scheme
      // Example:
      8'b00000001: irr <= 8'b00000001; // Highest priority is peripheral 0
      8'b00000010: irr <= 8'b00000010; // Priority is peripheral 1
      // Add similar cases for priorities of peripherals 2-7
      
      default: irr <= 8'b00000000; // No interrupts
    endcase
  end

  // IMR Logic
  always @(posedge clk) begin
    if (enable_gie) begin
      imr <= enable_pie & ~isr; // Update IMR based on enabled interrupts and servicing interrupts
    end
  end

  // Combined logic to generate interrupt when all conditions are met for enabled peripherals
  always @(posedge clk) begin
    if (enable_gie) begin
      if ((|pie) && (|pif) && gie) begin
        interrupt <= 1;
      end else begin
        interrupt <= 0;
      end
    end else begin
      interrupt <= 0;
    end

    // Store indices of valid interrupts in the latch
    if (enable_gie) begin
      valid_interrupts_latch <= 8'b0;
      for (i = 0; i < 8; i = i + 1) begin
        if (enable_pie[i] && pif[i]) begin
          valid_interrupts_latch[i] <= 1;
        end
      end
    end
  end

  // Assign the latch to the output
  assign valid_interrupts = valid_interrupts_latch;

endmodule
