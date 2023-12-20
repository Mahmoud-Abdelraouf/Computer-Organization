/**
* @brief Interrupt Mask Register (IMR) 8-bit register which contains 
* the interrupt request lines which are masked.
* 
* - This module is conneted to the OCW1 line to know which IR is masked.
* - Connected to the control logic with writeIMR signal, if it is active, the IMW 
* valuse are printed to the dataBuffer so the cpu read it.
* - bitToMask is connected to the IRR module, if a bit is one, than the corresponding 
* IR is masked and rejected.
* - dataBuffer lines are connected to the Data Buffer module.
*/
module IMR(
  input wire [7:0] OCW1,
  input wire writeIMR,
  output wire [7:0] bitToMask,
  output reg [7:0] dataBuffer
);
//compinational circuit.
assign bitToMask = OCW1;

//Async circuit.
always@ (writeIMR) begin
  if(writeIMR == 1)
    dataBuffer <= OCW1;
  else
    dataBuffer <= 8'bz;
end

endmodule