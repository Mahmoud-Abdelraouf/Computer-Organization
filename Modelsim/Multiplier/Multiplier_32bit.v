module Multiplier_32bit (
    input wire [31:0] A, // 32-bit input A
    input wire [31:0] B, // 32-bit input B
    output reg [63:0] Result // 64-bit output (multiplication result)
);
    wire [7:0] A_part [7:0];
    wire [7:0] B_part [7:0];
    wire [15:0] PartialResults [7:0];
    
    // Split 32-bit inputs into 8 groups of 4 bits
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : PARTITION
            assign A_part[i] = A[i*4 +: 4];
            assign B_part[i] = B[i*4 +: 4];
            Multiplier_4bit mult_inst (
                .A(A_part[i]),
                .B(B_part[i]),
                .Result(PartialResults[i])
            );
        end
    endgenerate
    
    // Combine the partial results to form the 32-bit output
    always @(*) begin
        Result = {
            PartialResults[7],
            PartialResults[6],
            PartialResults[5],
            PartialResults[4],
            PartialResults[3],
            PartialResults[2],
            PartialResults[1],
            PartialResults[0]
        };
    end
endmodule // Multiplier_32bit
