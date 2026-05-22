module ImmGen #(parameter Width = 32) (
    input  [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    wire [6:0] opcode = inst[6:0];
    always @(*) begin
        case(opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I-type
                imm = {{20{inst[31]}}, inst[31:20]};
            7'b0100011: // S-type
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            7'b1100011: // B-type (Shifted by 1 built-in)
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            7'b1101111: // J-type (Shifted by 1 built-in)
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            default: imm = 0;
        endcase
    end
endmodule