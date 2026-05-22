module PipelinedCPU (
    input clk,
    input start
);

// --- WIRES ---
wire [31:0] pc_current, pc_next, pc_plus4, instruction;
wire stall, flush_if_id, flush_id_ex;

wire [31:0] ifid_pc, ifid_inst;
wire id_branch, id_memRead, id_memtoReg, id_memWrite, id_ALUSrc, id_regWrite, id_jump_ctrl;
wire [1:0]  id_ALUOp;
wire [31:0] id_readData1, id_readData2, id_imm;
wire [31:0] id_pc_plus4 = ifid_pc + 4;

wire is_jal    = (ifid_inst[6:0] == 7'b1101111);
wire is_jalr   = (ifid_inst[6:0] == 7'b1100111);
wire is_branch = (ifid_inst[6:0] == 7'b1100011);
wire id_jump   = is_jal || is_jalr;

// --- ID STAGE BRANCH RESOLUTION ---
reg id_branch_taken;
always @(*) begin
    if (is_branch) begin
        case(ifid_inst[14:12])
            3'b000: id_branch_taken = (id_readData1 == id_readData2);                   // beq
            3'b001: id_branch_taken = (id_readData1 != id_readData2);                   // bne
            3'b100: id_branch_taken = ($signed(id_readData1) < $signed(id_readData2));  // blt
            3'b101: id_branch_taken = ($signed(id_readData1) >= $signed(id_readData2)); // bge
            default: id_branch_taken = 0;
        endcase
    end else if (id_jump) begin
        id_branch_taken = 1; // Jumps are always taken
    end else begin
        id_branch_taken = 0;
    end
end

wire [31:0] branch_target;
// JALR masks out the LSB per RISC-V spec. Normal branches/JAL just add immediate to PC.
assign branch_target = is_jalr ? ((id_readData1 + id_imm) & ~32'b1) : (ifid_pc + id_imm);

wire idex_memRead, idex_memtoReg, idex_memWrite, idex_ALUSrc, idex_regWrite, idex_jump;
wire [1:0]  idex_ALUOp;
wire [31:0] idex_pc, idex_rd1, idex_rd2, idex_imm, idex_pc_plus4;
wire [4:0]  idex_rs1, idex_rs2, idex_rd;
wire [2:0]  idex_funct3;
wire        idex_funct7;

wire [1:0]  forwardA, forwardB;
wire [31:0] aluA, aluB;
wire [3:0]  ALUCtl;
wire [31:0] ALUOut;
wire zero;

wire exmem_memRead, exmem_memtoReg, exmem_memWrite, exmem_regWrite, exmem_jump;
wire [31:0] exmem_ALUOut, exmem_readData2, exmem_pc_plus4;
wire [4:0]  exmem_rd;

wire [31:0] mem_readData;
wire memwb_memtoReg, memwb_regWrite, memwb_jump;
wire [31:0] memwb_memData, memwb_ALUOut, memwb_pc_plus4;
wire [4:0]  memwb_rd;
wire [31:0] wb_writeData;

// The data we actually write to the register. If it was a Jump, we write PC+4 (Link address)
assign wb_writeData = memwb_jump ? memwb_pc_plus4 : (memwb_memtoReg ? memwb_memData : memwb_ALUOut);

wire pc_src = id_branch_taken && !stall;

// ================= STAGE 1: FETCH =================
PC m_PC (.clk(clk), .rst(start), .stall(stall), .pc_i(pc_next), .pc_o(pc_current));
Adder m_Adder_PC (.a(pc_current), .b(32'd4), .sum(pc_plus4));

Mux2to1 #(32) m_Mux_PC (
    .sel(pc_src),
    .s0(pc_plus4), 
    .s1(branch_target),
    .out(pc_next)
);

InstructionMemory m_InstMem (.readAddr(pc_current), .inst(instruction));

IF_ID m_IF_ID (
    .clk(clk), .rst(start), .stall(stall), .flush(flush_if_id),
    .pc_in(pc_current), .inst_in(instruction),
    .pc_out(ifid_pc), .inst_out(ifid_inst)
);

// ================= STAGE 2: DECODE =================
Control m_Control (
    .opcode(ifid_inst[6:0]), .branch(id_branch), .memRead(id_memRead), .memtoReg(id_memtoReg),
    .ALUOp(id_ALUOp), .memWrite(id_memWrite), .ALUSrc(id_ALUSrc), .regWrite(id_regWrite), .jump(id_jump_ctrl)
);

Register m_Register (
    .clk(clk), .rst(start), .regWrite(memwb_regWrite),
    .readReg1(ifid_inst[19:15]), .readReg2(ifid_inst[24:20]), .writeReg(memwb_rd),
    .writeData(wb_writeData), .readData1(id_readData1), .readData2(id_readData2)
);

ImmGen m_ImmGen (.inst(ifid_inst), .imm(id_imm));

ID_EX m_ID_EX (
    .clk(clk), .rst(start), .flush(flush_id_ex),
    .memRead_in(id_memRead), .memtoReg_in(id_memtoReg), .ALUOp_in(id_ALUOp), .memWrite_in(id_memWrite),
    .ALUSrc_in(id_ALUSrc), .regWrite_in(id_regWrite), .jump_in(id_jump), .pc_plus4_in(id_pc_plus4),
    .pc_in(ifid_pc), .readData1_in(id_readData1), .readData2_in(id_readData2), .imm_in(id_imm),
    .rs1_in(ifid_inst[19:15]), .rs2_in(ifid_inst[24:20]), .rd_in(ifid_inst[11:7]),
    .funct3_in(ifid_inst[14:12]), .funct7_in(ifid_inst[30]),
    
    .memRead_out(idex_memRead), .memtoReg_out(idex_memtoReg), .ALUOp_out(idex_ALUOp), .memWrite_out(idex_memWrite),
    .ALUSrc_out(idex_ALUSrc), .regWrite_out(idex_regWrite), .jump_out(idex_jump), .pc_plus4_out(idex_pc_plus4),
    .pc_out(idex_pc), .readData1_out(idex_rd1), .readData2_out(idex_rd2), .imm_out(idex_imm),
    .rs1_out(idex_rs1), .rs2_out(idex_rs2), .rd_out(idex_rd), .funct3_out(idex_funct3), .funct7_out(idex_funct7)
);

// ================= STAGE 3: EXECUTE =================
ForwardingUnit m_Forward (
    .id_ex_rs1(idex_rs1), .id_ex_rs2(idex_rs2),
    .ex_mem_rd(exmem_rd), .ex_mem_regWrite(exmem_regWrite),
    .mem_wb_rd(memwb_rd), .mem_wb_regWrite(memwb_regWrite),
    .forwardA(forwardA), .forwardB(forwardB)
);

// Forwarding Muxes for Source A
wire [31:0] aluA_final;
Mux2to1 #(32) m_FwdA1 (.sel(forwardA[1]), .s0(idex_rd1), .s1(exmem_ALUOut), .out(aluA));
Mux2to1 #(32) m_FwdA2 (.sel(forwardA[0] & ~forwardA[1]), .s0(aluA), .s1(wb_writeData), .out(aluA_final));

// Forwarding Muxes for Source B
wire [31:0] aluB_fwd, aluB_fwd_final;
Mux2to1 #(32) m_FwdB1 (.sel(forwardB[1]), .s0(idex_rd2), .s1(exmem_ALUOut), .out(aluB_fwd));
Mux2to1 #(32) m_FwdB2 (.sel(forwardB[0] & ~forwardB[1]), .s0(aluB_fwd), .s1(wb_writeData), .out(aluB_fwd_final));

// Decide if ALU uses register data or the immediate value
Mux2to1 #(32) m_Mux_ALUSrc (.sel(idex_ALUSrc), .s0(aluB_fwd_final), .s1(idex_imm), .out(aluB));

ALUCtrl m_ALUCtrl (.ALUOp(idex_ALUOp), .funct7(idex_funct7), .funct3(idex_funct3), .ALUCtl(ALUCtl));
ALU m_ALU (.ALUCtl(ALUCtl), .A(aluA_final), .B(aluB), .ALUOut(ALUOut), .zero(zero));

EX_MEM m_EX_MEM (
    .clk(clk), .rst(start),
    .memRead_in(idex_memRead), .memtoReg_in(idex_memtoReg), .memWrite_in(idex_memWrite), .regWrite_in(idex_regWrite),
    .jump_in(idex_jump), .pc_plus4_in(idex_pc_plus4), .ALUOut_in(ALUOut), .readData2_in(aluB_fwd_final), .rd_in(idex_rd),
    
    .memRead_out(exmem_memRead), .memtoReg_out(exmem_memtoReg), .memWrite_out(exmem_memWrite), .regWrite_out(exmem_regWrite),
    .jump_out(exmem_jump), .pc_plus4_out(exmem_pc_plus4), .ALUOut_out(exmem_ALUOut), .readData2_out(exmem_readData2), .rd_out(exmem_rd)
);

// ================= STAGE 4: MEMORY =================
DataMemory m_DataMemory (
    .rst(start), .clk(clk),
    .memWrite(exmem_memWrite), .memRead(exmem_memRead),
    .address(exmem_ALUOut), .writeData(exmem_readData2),
    .readData(mem_readData)
);

MEM_WB m_MEM_WB (
    .clk(clk), .rst(start),
    .memtoReg_in(exmem_memtoReg), .regWrite_in(exmem_regWrite), .jump_in(exmem_jump),
    .pc_plus4_in(exmem_pc_plus4), .memData_in(mem_readData), .ALUOut_in(exmem_ALUOut), .rd_in(exmem_rd),
    
    .memtoReg_out(memwb_memtoReg), .regWrite_out(memwb_regWrite), .jump_out(memwb_jump),
    .pc_plus4_out(memwb_pc_plus4), .memData_out(memwb_memData), .ALUOut_out(memwb_ALUOut), .rd_out(memwb_rd)
);

// ================= HAZARD DETECTION =================
HazardDetection m_Hazard (
    .id_ex_memRead(idex_memRead), .id_ex_regWrite(idex_regWrite), .id_ex_rd(idex_rd),
    .ex_mem_regWrite(exmem_regWrite), .ex_mem_rd(exmem_rd),
    .if_id_rs1(ifid_inst[19:15]), .if_id_rs2(ifid_inst[24:20]),
    .id_is_branch(is_branch), .id_is_jalr(is_jalr), .id_branch_taken(id_branch_taken),
    .stall(stall), .flush_id_ex(flush_id_ex), .flush_if_id(flush_if_id)
);

endmodule