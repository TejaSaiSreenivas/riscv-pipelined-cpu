module ALUCtrl (
    input  [1:0] ALUOp,
    input        funct7,
    input  [2:0] funct3,
    output reg [3:0] ALUCtl
);
    always @(*) begin
        case(ALUOp)
            2'b00: ALUCtl = 4'b0010; // ADD (for memory addresses)
            2'b01: ALUCtl = 4'b0110; // SUB (for branch comparisons)
            2'b10, 2'b11: begin      // R-type or I-type
                case(funct3)
                    3'b000: ALUCtl = funct7 ? 4'b0110 : 4'b0010; // sub/add
                    3'b111: ALUCtl = 4'b0000; // and
                    3'b110: ALUCtl = 4'b0001; // or
                    3'b100: ALUCtl = 4'b0011; // xor
                    3'b001: ALUCtl = 4'b0100; // sll
                    3'b101: ALUCtl = funct7 ? 4'b1000 : 4'b0101; // sra/srl
                    3'b010: ALUCtl = 4'b0111; // slt
                    3'b011: ALUCtl = 4'b1001; // sltu
                    default: ALUCtl = 4'b0010;
                endcase
            end
            default: ALUCtl = 4'b0010;
        endcase
    end
endmodule