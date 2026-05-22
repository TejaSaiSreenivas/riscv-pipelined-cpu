module InstructionMemory (
    input [31:0] readAddr,
    output [31:0] inst
);
    // Do not modify this file!
    reg [7:0] insts [127:0];
    
    // Fetch 4 individual bytes to form a 32-bit instruction
    assign inst = (readAddr >= 128) ? 32'b0 : 
                  {insts[readAddr], insts[readAddr + 1], insts[readAddr + 2], insts[readAddr + 3]};
                  
    initial begin
        // The $readmemb command loads your machine code into this array
        $readmemb("TEST_INSTRUCTIONS.dat", insts);
    end
endmodule