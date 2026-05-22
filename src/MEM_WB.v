module MEM_WB (
    input clk, rst,
    input memtoReg_in, regWrite_in, jump_in,
    input [31:0] pc_plus4_in, memData_in, ALUOut_in,
    input [4:0] rd_in,

    output reg memtoReg_out, regWrite_out, jump_out,
    output reg [31:0] pc_plus4_out, memData_out, ALUOut_out,
    output reg [4:0] rd_out
);
    always @(posedge clk) begin
        if (~rst) begin
            memtoReg_out<=0; regWrite_out<=0; jump_out<=0;
            pc_plus4_out<=0; memData_out<=0; ALUOut_out<=0; rd_out<=0;
        end
        else begin
            memtoReg_out<=memtoReg_in; regWrite_out<=regWrite_in; jump_out<=jump_in;
            pc_plus4_out<=pc_plus4_in; memData_out<=memData_in; 
            ALUOut_out<=ALUOut_in; rd_out<=rd_in;
        end
    end
endmodule