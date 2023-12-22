
`timescale 1ns / 1ps

module CascadeController_tb;

  // Inputs
  reg SP1,SP2,SP3;
  reg [7:0] ICW3_1 , ICW3_2 ,ICW3_3   ;
  reg control_signal_1 ,control_signal_2, control_signal_3;
  reg [2:0] desired_slave;

  // Outputs
  wire [2:0] CAS;
  wire flag,flag2,flag3;
  
  
// Instantiation of the CascadeController module for Pic1
CascadeController Pic1 (
  .CAS(CAS),
  .SP(SP1),
  .ICW3(ICW3_1),
  .control_signal(control_signal_1),
  .desired_slave(desired_slave),
  .flag(flag)
);

// Instantiation of the CascadeController module for Pic2
CascadeController Pic2 (
  .CAS(CAS),
  .SP(SP2),
  .ICW3(ICW3_2),
  .control_signal(control_signal_2),
  .desired_slave(desired_slave),
  .flag(flag2)
);

// Instantiation of the CascadeController module for Pic3
CascadeController Pic3 (
  .CAS(CAS),
  .SP(SP3),
  .ICW3(ICW3_3),
  .control_signal(control_signal_3),
  .desired_slave(desired_slave),
  .flag(flag3)
);


// Initial block: for initialization
initial begin
  // Initialize inputs for Pic1
  SP1 = 1; // Pic1 operates in MASTER Mode
  SP2=0 ; // Pic2 is a slave
  SP3=0 ; // Pic3 is a slave 
  ICW3_1 = 8'b00000000; // The last 3 bits are 000 Which is the casecade ID of this pic (But it is a Master)
  ICW3_2 = 8'b00000110; // Cascade ID 110
  ICW3_3 = 8'b00000111; // Cascade ID 111
  
  control_signal_1 = 0; // Initial value for control signal
  control_signal_2 = 0;
  control_signal_3 = 0;
  
  desired_slave = 3'b010; // Firstly we are goning to choose an unavailable slave 

  control_signal_1 = 1; // Nothing should occure here because and the CAS 010 (set by Master) doesn't match any slave (only avaialbe is 110 & 111)
  control_signal_2 = 1;
  control_signal_3 = 1;
  
  
  #100;

  // Turning off the operation
  control_signal_1 = 0;
  control_signal_2 = 0;
  control_signal_3 = 0;


  // Now , choosing Pic 2
  desired_slave = 3'b110; // The last three bits are 110 which matches CAS[2:0] of the instance pic2

  control_signal_1 = 1; // Flag2 of Pic2 should arise and the CAS 110 (set by Master) ID of PIC2
  control_signal_2 = 1;
  control_signal_3 = 1;
  
  #100; 

  // Turning off the operation
  control_signal_1 = 0;
  control_signal_2 = 0;
  control_signal_3 = 0;


  #10;

  // Now , choosing Pic 3
  desired_slave = 3'b111; // The last three bits are 111 which matches CAS[2:0] of the instance Pic3

  control_signal_1 = 1; // Flag3 of Pic3 should arise as the CAS 111 (set by Master) ID of PIC2
  control_signal_2 = 1;
  control_signal_3 = 1;
  #100; 

  // Turning off the operation
  control_signal_1 = 0;
  control_signal_2 = 0;
  control_signal_3 = 0;

  #10;

  
end


  // You can add additional always blocks or tasks for stimulus generation and checking results

endmodule


