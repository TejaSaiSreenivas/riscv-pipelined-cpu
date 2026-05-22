module ALU (
    input  [3:0]  ALUCtl,
    input  [31:0] A, B,
    output reg [31:0] ALUOut,
    output zero
);
    always @(*) begin
        case(ALUCtl)
            4'b0000: ALUOut = A & B;
            4'b0001: ALUOut = A | B;
            4'b0010: ALUOut = A + B;
            4'b0011: ALUOut = A ^ B;
            4'b0100: ALUOut = A << B[4:0];
            4'b0101: ALUOut = A >> B[4:0];
            4'b0110: ALUOut = A - B;
            4'b0111: ALUOut = ($signed(A) < $signed(B)) ? 1 : 0; // SLT handles signed numbers
            4'b1000: ALUOut = $signed(A) >>> B[4:0];
            4'b1001: ALUOut = (A < B) ? 1 : 0;
            default: ALUOut = 0;
        endcase
    end
    assign zero = (ALUOut == 0);
endmodule