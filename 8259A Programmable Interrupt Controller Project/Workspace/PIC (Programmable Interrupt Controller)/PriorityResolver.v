module PriorityResolver(
  input wire freezing,
  input wire [7:0] IRR_reg, //connected to ISR to get its reg values.
  input wire [7:0] ISR_reg, //connected to ISR to get its reg values.
  input wire [7:0] OCW2, //connected to the OCW2 reg to know the mode.
  output reg [2:0] serviced_interrupt_index, //connected to ISR (index to set) or to IRR (index to reset) the corresponding bit.
  output INT_request //connected to the control logic to fire a new interrupt
);
  
  reg [7:0] interrupt_indexes; //Register to store valid interrupt indexes.
  reg [1:0] currentMode; //Register to store the current mode active according to OCW2.
  wire [2:0] modesFromOCW2; //wire that holds the values of (D7,D6,D5) of OCW2. 
  reg resolveFlag; //Flag to start resolving the current priority.
  
  /*
   * Assign wires
   */
   assign modesFromOCW2 = OCW2[7:5];
   
  /*
   * localparam for the OCW2 modes (in this order: D7,D6,D5)
   */
  //For Fully Nested mode
  localparam NON_SPECIFIC_EOI                 = 3'b001;
  localparam SPECIFIC_EOI                     = 3'b011;
  //For Automatic Rotation mode
  localparam ROTATE_ON_NON_SPECIFIC_EOI       = 3'b101;
  localparam ROTATE_ON_AUTO_EOI_set           = 3'b100; //??
  localparam ROTATE_ON_AUTO_EOI_clear         = 3'b000; //??
  //For Specific rotation (out of scope)
  localparam ROTATE_ON_SPECIFIC_EOI           = 3'b111; 
  localparam SET_PRIORITY                     = 3'b110;
  //No operation ??
  localparam NO_OPERATION                     = 3'b010; //??
  
  /*
   * Values of each mode
   */
   localparam FULLY_NESTED_MODE = 2'b00;
   localparam AUTO_ROTATION_MODE = 2'b01;
   
  /*
   * Set the mode according to the value of OCW2.
   */
   always @(modesFromOCW2) begin
     case (modesFromOCW2)
      //Fully nested mode
      NON_SPECIFIC_EOI: currentMode <= FULLY_NESTED_MODE;
      SPECIFIC_EOI: currentMode <= FULLY_NESTED_MODE;
      //Automatic Rotation mode
      ROTATE_ON_NON_SPECIFIC_EOI: currentMode <= AUTO_ROTATION_MODE;
      ROTATE_ON_AUTO_EOI_set: currentMode <= AUTO_ROTATION_MODE;
      ROTATE_ON_AUTO_EOI_clear: currentMode <= AUTO_ROTATION_MODE;
    endcase
   end
   
  
  /*
   * On any change in IRR regester --> resolve the priority, 
   * read ISR to determine its value too.
   */
  always @(IRR_reg) begin
    //save the values of IRR or not according to freezing flag.
    if(freezing) begin
      interrupt_indexes = interrupt_indexes; //Store valid interrupts and freeze it.
    end else begin
      interrupt_indexes = IRR_reg; //Get the new values from the IRR.
    end
    
    /*
     * Start resolving
     */
     resolveFlag = 1;
     #5 resolveFlag = 0;
     
  end
  
  /*
   * Resolving block according to the mode.
   */
   integer i; //for loop
   always @(posedge resolveFlag) begin
     //Do the resolving according to the mode.
     case (currentMode)
       FULLY_NESTED_MODE: begin
         //TODO: the code here is the old version, update it.
         // Loop to find the lowest numbered peripheral with an interrupt
        for (i = 0; i < 8; i = i + 1) begin
          if (interrupt_indexes[i]) begin
            serviced_interrupt_index = i; // Assign lowest numbered peripheral with an interrupt
            i = 8; // Exit the loop once the interrupt is found
          end
        end  
       end
       
       AUTO_ROTATION_MODE: begin
         
         
       end
    endcase
   end
  
endmodule