module IF_ID (
    input clk, rst, stall, flush,
    input [31:0] pc_in, inst_in,
    output reg [31:0] pc_out, inst_out
);
    always @(posedge clk) begin
        if (~rst || flush) begin
            pc_out   <= 32'b0;
            inst_out <= 32'h00000013; // Inject a NOP (addi x0, x0, 0)
        end
        else if (!stall) begin
            pc_out   <= pc_in;
            inst_out <= inst_in;
        end
    end
endmodule