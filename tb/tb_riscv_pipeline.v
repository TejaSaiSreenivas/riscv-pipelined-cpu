`timescale 1ns / 1ps

module tb_riscv_pipeline;

    reg clk;
    reg start;

    PipelinedCPU riscv_DUT (clk, start);

    // Generate a 10-unit clock period
    initial forever #5 clk = ~clk;

    initial begin
        $dumpfile("wave_pipeline.vcd");
        $dumpvars(0, tb_riscv_pipeline);
        
        clk   = 0;
        start = 0; // Hold reset low
        
        #10 start = 1; // Release reset
        
        #500;

        $display("=== Register File Dump ===");
        $display("x0  = %0d", riscv_DUT.m_Register.regs[0]);
        $display("x1  = %0d", riscv_DUT.m_Register.regs[1]);
        $display("x2  = %0d", riscv_DUT.m_Register.regs[2]);
        $display("x3  = %0d", riscv_DUT.m_Register.regs[3]);
        $display("x4  = %0d", riscv_DUT.m_Register.regs[4]);
        $display("x5  = %0d", riscv_DUT.m_Register.regs[5]);
        $display("x6  = %0d", riscv_DUT.m_Register.regs[6]);
        $display("x7  = %0d", riscv_DUT.m_Register.regs[7]);
        $display("x8  = %0d", riscv_DUT.m_Register.regs[8]);
        $display("x9  = %0d", riscv_DUT.m_Register.regs[9]);
        $display("x10 = %0d", riscv_DUT.m_Register.regs[10]);
        $display("x11 = %0d", riscv_DUT.m_Register.regs[11]);
        $display("x12 = %0d", riscv_DUT.m_Register.regs[12]);

        $display("=== Data Memory (word-addressed) ===");
        $display("mem[0]  = %0d", {riscv_DUT.m_DataMemory.data_memory[3],
                                   riscv_DUT.m_DataMemory.data_memory[2],
                                   riscv_DUT.m_DataMemory.data_memory[1],
                                   riscv_DUT.m_DataMemory.data_memory[0]});
                                   
        $display("mem[4]  = %0d", {riscv_DUT.m_DataMemory.data_memory[7],
                                   riscv_DUT.m_DataMemory.data_memory[6],
                                   riscv_DUT.m_DataMemory.data_memory[5],
                                   riscv_DUT.m_DataMemory.data_memory[4]});
                                   
        $display("mem[8]  = %0d", {riscv_DUT.m_DataMemory.data_memory[11],
                                   riscv_DUT.m_DataMemory.data_memory[10],
                                   riscv_DUT.m_DataMemory.data_memory[9],
                                   riscv_DUT.m_DataMemory.data_memory[8]});
                                   
        $display("mem[12] = %0d", {riscv_DUT.m_DataMemory.data_memory[15],
                                   riscv_DUT.m_DataMemory.data_memory[14],
                                   riscv_DUT.m_DataMemory.data_memory[13],
                                   riscv_DUT.m_DataMemory.data_memory[12]});

        $display("=== Pipeline Signals at end ===");
        $display("PC        = %0d", riscv_DUT.pc_current);
        $display("stall     = %0d", riscv_DUT.stall);
        $display("flush_if  = %0d", riscv_DUT.flush_if_id);
        $display("flush_idex= %0d", riscv_DUT.flush_id_ex);

        #4500 $finish;
    end

endmodule