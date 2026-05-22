module HazardDetection (
    input        id_ex_memRead, id_ex_regWrite, ex_mem_regWrite,
    input  [4:0] id_ex_rd, ex_mem_rd, if_id_rs1, if_id_rs2,
    input        id_is_branch, id_is_jalr, id_branch_taken,
    output reg   stall, flush_id_ex, flush_if_id
);
    // Since we resolve branches in the ID stage, we need the register data NOW. 
    // If the data is still being calculated in EX or MEM, forwarding can't save us in time. We MUST stall.
    wire branch_rs1_dep = (id_is_branch || id_is_jalr) && (if_id_rs1 != 0) &&
                          ((id_ex_regWrite && (id_ex_rd == if_id_rs1)) || (ex_mem_regWrite && (ex_mem_rd == if_id_rs1)));
                          
    wire branch_rs2_dep = id_is_branch && (if_id_rs2 != 0) &&
                          ((id_ex_regWrite && (id_ex_rd == if_id_rs2)) || (ex_mem_regWrite && (ex_mem_rd == if_id_rs2)));
                          
    wire branch_stall = branch_rs1_dep || branch_rs2_dep;

    always @(*) begin
        stall = 0; flush_id_ex = 0; flush_if_id = 0;

        // 1. Load-Use Data Hazard OR Branch Dependency
        if ((id_ex_memRead && (id_ex_rd != 0) && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) || branch_stall) begin
            stall = 1;
            flush_id_ex = 1;  // Turn the instruction entering EX into a harmless NOP (bubble)
        end
        // 2. Control Hazard (Branch Actually Taken)
        else if (id_branch_taken) begin
            flush_if_id = 1;  // The instruction we just fetched is wrong. Flush it.
        end
    end
endmodule