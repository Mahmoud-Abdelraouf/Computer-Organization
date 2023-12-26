module PIC_TopModule
  (
  input wire VCC, //Conected to Control logic
  input wire GND, //Conected to Control logic
  input wire INTA, //Conected to Control logic from CPU
  output wire INT, //Conected to Control logic to CPU 
  inout wire [7:0] sys_DataLine, //D0 - D7
  input wire RD, // Read / Write Logic
  input wire WR, // Read / Write Logic
  input wire A0, // input to Read / Write Logic
  input wire CS, // 8 bit data input to read / write logic
  input wire [3:0] CAS, // cascade controller
  input wire SP_EN,  // enable and decide cascade mode
  input wire [7:0] IR0_to_IR7
  
  );
  
  
  
  wire [7:0] internalDATABus;  // connecting data to all blocks
  
  wire [7:0] ICW1,					// Output : Initialization Command Word 1 (8 bits).				
  wire [7:0] ICW2,					// Output : Initialization Command Word 2 (8 bits).
  wire [7:0] ICW3,					// Output : Initialization Command Word 3 (8 bits).
  wire [7:0] ICW4,					// Output : Initialization Command Word 4 (8 bits).
  wire [7:0] OCW1,					// Output : Operation Command Word 1 (8 bits).
  wire [7:0] OCW2,					// Output : Operation Command Word 2 (8 bits).
  wire [7:0] OCW3,					// Output : Operation Command Word 3 (8 bits). 
  
  
  wire rd;  // from Read flag logic to data bus buffer
  wire wr;  // from write flag logic to data bus buffer
  
  
  //Making an instance of Databus buffer
    DataBusBuffer dataBusBuffer (
    .data_inside(internalDATABus),
    .data_outside(sys_DataLine),
    .rd(rd),
    .wr(wr)
  ); 
  
  // Making an instanec of readWrirelLogic
  ReadWriteLogic readWriteLogic(
    .Read(RD),
    .write(WR),
    .A0(A0),
    .CS(CS),
    .dataBuffer(internalDATABus),
    .write_flag(wr),
    .ICW1(ICW1),
    .ICW2(ICW2),
    .ICW3(ICW3),
    .ICW4(ICW4),
    .OCW1(OCW1),
    .OCW2(OCW2),
    .OCW3(OCW3),
    .read_cmd_to_ctrl_logic(read_cmd_to_ctrl_logic),
    .OCW3_change(OCW3_change),
    .read_cmd_imr_to_ctrl_logic(read_cmd_imr_to_ctrl_logic),
    .read_flag(rd));
    
    
    
    // Instantiation of the CascadeController module for master
CascadeController master (
  .CAS(CAS), //done
  .SP(SP), //done 
  .ICW3(ICW3), // done
  .control_signal(cascade_signal), // from control logic
  .desired_slave(desired_slave),  // from control logic
  .flag_ACK(cascade_flag_ACK), // from control logic
  .flag(cascade_flag),  // to control logic
  .control_signal_ack(control_signal_ack), // from control logic
  .SP_to_control(SP_to_control), // to control logic
  .EOI(EOI_to_cascade) // from control logic
);

 InterruptMaskRegister IMR_inst(
    .OCW1(OCW1),    // OCW1 commands to know which bits are masked, connected to the R/D logic.
    .readIMR(read_IMR),  //done    // To put the IMR_reg into the internal data lines, connected to the control logic.
    .IMR_reg(IMR_reg),  // done  // IMR (status) register, connected to IRR.
    .dataBuffer(internalDATABus)  // Internal data bus that is connected to the data buffer.
  );
  
  
  
  
    // Instantiate the InterruptRequestRegister module
    InterruptRequestRegister irr_inst (
        .IR0_to_IR7(IR0_to_IR7),  //done comes from outside the module
        .bitToMask(IMR_reg),    // comes from imr
        .readPriority(readPriority), // done from control logic
        .readIRR(readIRR),  // done from control logic
        .resetIRR(serviced_interrupt_index), //comes from priority resolver
        .ICW1(ICW1), //done comes from read write logic
        .risedBits(risedBits), // to priority resolver
        .dataBuffer(internalDATABus), // done
        .readPriorityAck(read_priority_ACK) // done  // come from control logic
    );
    
    
    
    
       // Instantiate the InterruptRequestRegister module
    PriorityResolver pr_inst(
        .freezing(freezing),   ////done comes from read write logic
        .IRR_reg(risedBits),  // comes from irr 
        .ISR_reg(isrRegValue),  // from isr 
        .resetedISR_index(resetedIndex), // from isr
        .OCW2(OCW2),  ////done comes from read write logic
        .INT_requestAck, /// TODO: .(INT_request_ACK) Ya Abdelraof
        .serviced_interrupt_index(serviced_interrupt_index), // goes to irr and isr
        .zeroLevelPriorityBit(zeroLevelPriorityBit), // to isr
        .INT_request(INT_request) // to control logic
    );
  
  
   // Instantiate the module
    InServiceRegister isr_inst (
        .toSet(serviced_interrupt_index), // from priority resolver and goes to irr as well
        .readPriority(readPriority),
        .readIsr(readIsr),
        .sendVector(sendVector),
        .zeroLevelIndex(zeroLevelPriorityBit),  //from priority resolver
        .ICW2(ICW2), // done from read write logic
        .ICW4(ICW4),  // done from read write logic
        .secondACK(secondACK),
        .changeInOCW2(changeInOCW2),
        .OCW2(OCW2),  // done from read write logic
        .INTIndex(INTIndex),
        .dataBuffer(internalDATABus), //Done
        .isrRegValue(isrRegValue),  //done
        .resetedIndex(resetedIndex),  // done 
        .sendVectorAck(sendVectorAck)
    );
    
    
    
    // Instantiate the ControlLogic module
  ControlLogic control_logic_inst (
    .INTA(INTA),  // from cpu
    .INT_request(INT_request),   // from priority
    .read_priority_ACK(read_priority_ACK),  /// to IRR  
    .interrupt_index(interrupt_index),
    .send_vector_ISR_ACK(send_vector_ISR_ACK),
    .read_cmd_to_ctrl_logic(read_cmd_to_ctrl_logic),
    .OCW3(OCW3),  // done from read write logic 
    .write_flag(write_flag),
    .ICW3(ICW3),  // done from read write logic 
    .read_cmd_imr_to_ctrl_logic(read_cmd_imr_to_ctrl_logic),
    .ICW1(ICW1),  // done from read write logic   
    .cascade_flag(cascade_flag),  from cascade controller
    .SP(SP_to_control),  // from cascade controller
    .cascade_signal_ACK(control_signal_ack), // to cascasde controller
    .EOI(EOI),
    .INT(INT),// to cpu
    .read_IRR(read_IRR),  //to irr
    .read_priority(read_priority),  //to irr
    .freezing(freezing), // to priority
    .INT_request_ACK(INT_request_ACK), // to priority
    .read_IMR(read_IMR), // to imr
    .send_vector_ISR(send_vector_ISR),
    .read_ISR(read_ISR),
    .pulse_ACK(pulse_ACK),
    .second_ACK(second_ACK),
    .EOI_to_cascade(EOI_to_cascade), // to cascade controller
    .cascade_signal(cascade_signal), // to cascade controller
    .desired_slave(desired_slave),// to cascade controller
    .cascade_flag_ACK(cascade_flag_ACK)// to cascade controller
  );
    
    
  
  
endmodule
