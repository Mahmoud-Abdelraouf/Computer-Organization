module cascade_controller(
    inout [2:0]CAS,
    input SP,
    input INTA,
    input [2:0]PRIORITY_PIN,
    input CMD,
    input ID,
    output VECTOR,
);
localparam SLAVE=1'b0;
localparam MASTER=1'b1;

always @(negedge INTA) begin
    case (SP):
        SLAVE: begin
            if(ID==CAS)begin
                //send vector to data bus if the CAS matchs the current slave ID
            end
        end
        MASTER:begin
            //Send the slave ID we want
            CAS<=PRIORITY_PIN;
        end
    endcase
end
endmodule