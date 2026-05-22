module DataMemory(
    input rst, clk, memWrite, memRead,
    input [31:0] address, writeData,
    output reg [31:0] readData
);
    // Do not modify this file!
    reg [7:0] data_memory [127:0];
    integer i;

    always @ (posedge clk) begin
        if(~rst) begin
            for(i=0; i<128; i=i+1) data_memory[i] <= 8'b0;
        end
        else if(memWrite) begin
            // Store 32-bit word across 4 byte-addresses
            data_memory[address + 3] <= writeData[31:24];
            data_memory[address + 2] <= writeData[23:16];
            data_memory[address + 1] <= writeData[15:8];
            data_memory[address]     <= writeData[7:0];
        end
    end       

    always @(*) begin
        if(memRead) begin
            readData[31:24] = data_memory[address + 3];
            readData[23:16] = data_memory[address + 2];
            readData[15:8]  = data_memory[address + 1];
            readData[7:0]   = data_memory[address];
        end
        else readData = 32'b0;
    end
endmodule