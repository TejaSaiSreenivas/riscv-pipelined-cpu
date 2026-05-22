module EX_MEM (
    input clk, rst,
    input memRead_in, memtoReg_in, memWrite_in, regWrite_in, jump_in,
    input [31:0] pc_plus4_in, ALUOut_in, readData2_in,
    input [4:0] rd_in,

    output reg memRead_out, memtoReg_out, memWrite_out, regWrite_out, jump_out,
    output reg [31:0] pc_plus4_out, ALUOut_out, readData2_out,
    output reg [4:0] rd_out
);
    always @(posedge clk) begin
        if (~rst) begin
            memRead_out<=0; memtoReg_out<=0; memWrite_out<=0; regWrite_out<=0; jump_out<=0;
            pc_plus4_out<=0; ALUOut_out<=0; readData2_out<=0; rd_out<=0;
        end
        else begin
            memRead_out<=memRead_in; memtoReg_out<=memtoReg_in; memWrite_out<=memWrite_in;
            regWrite_out<=regWrite_in; jump_out<=jump_in; pc_plus4_out<=pc_plus4_in;
            ALUOut_out<=ALUOut_in; readData2_out<=readData2_in; rd_out<=rd_in;
        end
    end
endmodule