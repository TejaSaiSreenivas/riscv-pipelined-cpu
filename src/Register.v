module Register (
    input clk,
    input rst,
    input regWrite,
    input [4:0] readReg1, readReg2, writeReg,
    input [31:0] writeData,
    output [31:0] readData1, readData2
);
    reg [31:0] regs [0:31];

    // CRITICAL FIX: Internal Forwarding. 
    // If we read and write the exact same register in the same clock cycle, 
    // bypass the memory array and immediately output the new writeData.
    assign readData1 = (readReg1 != 0) ? ((regWrite && (writeReg == readReg1)) ? writeData : regs[readReg1]) : 0;
    assign readData2 = (readReg2 != 0) ? ((regWrite && (writeReg == readReg2)) ? writeData : regs[readReg2]) : 0;

    integer i;
    always @(posedge clk) begin
        if(~rst) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
            regs[2] <= 32'd128; // Standard stack pointer initialization
        end
        else if(regWrite && writeReg != 0) begin
            regs[writeReg] <= writeData;
        end
    end
endmodule