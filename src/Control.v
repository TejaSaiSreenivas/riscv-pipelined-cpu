module Control (
    input  [6:0] opcode,
    output reg branch, memRead, memtoReg, memWrite, ALUSrc, regWrite, jump,
    output reg [1:0] ALUOp
);
    always @(*) begin
        // Set defaults to prevent latches and make the switch statement cleaner
        branch=0; memRead=0; memtoReg=0; ALUOp=2'b00;
        memWrite=0; ALUSrc=0; regWrite=0; jump=0;
        
        case(opcode)
            7'b0110011: begin // R-type (add, sub, and, or, slt)
                ALUOp=2'b10; regWrite=1;
            end
            7'b0010011: begin // I-type (addi, andi, ori, slti)
                ALUOp=2'b11; ALUSrc=1; regWrite=1;
            end
            7'b0000011: begin // lw
                memRead=1; memtoReg=1; ALUSrc=1; regWrite=1;
            end
            7'b0100011: begin // sw
                memWrite=1; ALUSrc=1;
            end
            7'b1100011: begin // Branches (beq, bne, blt, bge)
                branch=1; ALUOp=2'b01;
            end
            7'b1101111: begin // jal
                ALUSrc=1; regWrite=1; jump=1;
            end
            7'b1100111: begin // jalr
                ALUSrc=1; regWrite=1; jump=1;
            end
        endcase
    end
endmodule