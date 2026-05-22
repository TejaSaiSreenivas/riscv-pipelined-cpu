module ID_EX (
    input clk, rst, flush,
    input memRead_in, memtoReg_in, memWrite_in, ALUSrc_in, regWrite_in, jump_in,
    input [1:0] ALUOp_in,
    input [31:0] pc_plus4_in, pc_in, readData1_in, readData2_in, imm_in,
    input [4:0] rs1_in, rs2_in, rd_in,
    input [2:0] funct3_in, input funct7_in,

    output reg memRead_out, memtoReg_out, memWrite_out, ALUSrc_out, regWrite_out, jump_out,
    output reg [1:0] ALUOp_out,
    output reg [31:0] pc_plus4_out, pc_out, readData1_out, readData2_out, imm_out,
    output reg [4:0] rs1_out, rs2_out, rd_out,
    output reg [2:0] funct3_out, output reg funct7_out
);
    always @(posedge clk) begin
        if (~rst || flush) begin
            memRead_out<=0; memtoReg_out<=0; ALUOp_out<=0; memWrite_out<=0; 
            ALUSrc_out<=0; regWrite_out<=0; jump_out<=0; pc_plus4_out<=0; 
            pc_out<=0; readData1_out<=0; readData2_out<=0; imm_out<=0;
            rs1_out<=0; rs2_out<=0; rd_out<=0; funct3_out<=0; funct7_out<=0;
        end
        else begin
            memRead_out<=memRead_in; memtoReg_out<=memtoReg_in; ALUOp_out<=ALUOp_in;
            memWrite_out<=memWrite_in; ALUSrc_out<=ALUSrc_in; regWrite_out<=regWrite_in;
            jump_out<=jump_in; pc_plus4_out<=pc_plus4_in; pc_out<=pc_in;
            readData1_out<=readData1_in; readData2_out<=readData2_in; imm_out<=imm_in;
            rs1_out<=rs1_in; rs2_out<=rs2_in; rd_out<=rd_in;
            funct3_out<=funct3_in; funct7_out<=funct7_in;
        end
    end
endmodule