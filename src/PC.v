module PC (
    input clk,
    input rst,
    input stall,
    input  [31:0] pc_i,
    output reg [31:0] pc_o
);
    always @(posedge clk) begin
        if (~rst)
            pc_o <= 32'b0; // Reset to instruction memory base
        else if (!stall)
            pc_o <= pc_i;  // Only update PC if we are not stalled by a hazard
    end
endmodule