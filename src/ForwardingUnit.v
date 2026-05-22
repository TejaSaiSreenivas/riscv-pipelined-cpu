module ForwardingUnit (
    input  [4:0] id_ex_rs1, id_ex_rs2, ex_mem_rd, mem_wb_rd,
    input        ex_mem_regWrite, mem_wb_regWrite,
    output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        // Data priority: EX/MEM is the most recent data, so check it first. 
        // If not there, check MEM/WB. Otherwise, use normal register output.
        
        // Forwarding for Source A (rs1)
        if (ex_mem_regWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1))
            forwardA = 2'b10;
        else if (mem_wb_regWrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1))
            forwardA = 2'b01;
        else
            forwardA = 2'b00;

        // Forwarding for Source B (rs2)
        if (ex_mem_regWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2))
            forwardB = 2'b10;
        else if (mem_wb_regWrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end
endmodule