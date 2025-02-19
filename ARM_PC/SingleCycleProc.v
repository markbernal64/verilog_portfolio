module singlecycle(
    input CLK,
    input resetl,
    input [63:0] startpc,
    output reg [63:0] currentpc,
    output [63:0] dmemout
);
    // Next PC connections
    wire [63:0] nextpc;       // The next PC, to be updated on clock cycle

    // Instruction Memory connections
    wire [31:0] instruction;  // The current instruction

    // Parts of instruction
    wire [4:0] rd;            // The destination register
    wire [4:0] rm;            // Operand 1
    wire [4:0] rn;            // Operand 2
    wire [10:0] opcode;

//---------------------------------------------------------------------------------
    wire [15:0] moveimm;
//--------------------------------------------------------------------------------


    // Control wires
    wire reg2loc;
    wire alusrc;
    wire mem2reg;
    wire regwrite;
    wire memread;
    wire memwrite;
    wire branch;
    wire uncond_branch;
    wire [3:0] aluctrl;
    wire [2:0] signop;

    // Register file connections
    wire [63:0] regoutA;     // Output A
    wire [63:0] regoutB;     // Output B

    // ALU connections
    wire [63:0] aluout;
    wire zero;

    // Sign Extender connections
    wire [25:0] inext;
    wire [63:0] extimm;

    // PC update logic
    always @(negedge CLK)
    begin
        if (resetl)
            currentpc <= nextpc;
        else
            currentpc <= startpc;
    end

    // Parts of instruction
    assign rd = instruction[4:0];
    assign rm = instruction[9:5];
    assign rn = reg2loc ? instruction[4:0] : instruction[20:16];
    assign opcode = instruction[31:21];
    assign inext = instruction[25:0];       //sign extender input

    InstructionMemory imem (
        .Data(instruction),
        .Address(currentpc)
    );

    control control (
        .reg2loc(reg2loc),
        .alusrc(alusrc),
        .mem2reg(mem2reg),
        .regwrite(regwrite),
        .memread(memread),
        .memwrite(memwrite),
        .branch(branch),
        .uncond_branch(uncond_branch),
        .aluop(aluctrl),
        .signop(signop),
        .opcode(opcode)
    );

    /*
    * Connect the remaining datapath elements below.
    * Do not forget any additional multiplexers that may be required.
    */

//------------------------------------------------------------------------
    //multiplexers
    wire [63:0] aluBin;
    wire [63:0] memMux;

    //mux for ALU BusB input
    assign aluBin = alusrc ? extimm : regoutB;

    //mux for Data Memory output
    assign memMux = mem2reg ? dmemout: aluout;

    //connecting register file
    RegisterFile Regfil (
          .BusA(regoutA),
          .BusB(regoutB),
          .BusW(memMux),
          .RW(rd),
          .RA(rm),
          .RB(rn),
          .RegWr(regwrite),
          .Clk(CLK)
    );

    //connecting pclogic
    NextPClogic pcLogic (
            .NextPC(nextpc),
            .CurrentPC(currentpc),
            .SignExtImm64(extimm),
            .Branch(branch),
            .ALUZero(zero),
            .Uncondbranch(uncond_branch)
    );

    //conecting sign extender
    SignExtender SignExt (
          .BusImm(extimm),
          .Imm26(inext),
          .Ctrl(signop)
    );

    //connecting ALU
    ALU ALU (
          .BusW(aluout),
          .BusA(regoutA),
          .BusB(aluBin),
          .ALUCtrl(aluctrl),
          .Zero(zero)
    );

    //connecting DataMemory
    DataMemory memory (
            .ReadData(dmemout),
            .Address(aluout),
            .WriteData(regoutB),
            .MemoryRead(memread),
            .MemoryWrite(memwrite),
            .Clock(CLK)
    );

endmodule
