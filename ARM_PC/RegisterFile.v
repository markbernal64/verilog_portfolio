module RegisterFile(BusA, BusB, BusW, RW, RA, RB, RegWr, Clk);
    output [63:0] BusA;
    output [63:0] BusB;
    input [63:0] BusW;
    input [4:0] RW, RA, RB;
    input RegWr;
    input Clk;

    //vector of 32 registers
    reg [63:0] registers [31:0];

    assign #2 BusA = registers[RA];     //BusA = register at RA
    assign #2 BusB = registers[RB];     //BusB = register at RB

    initial
        begin
            registers[31] <= 64'b0;     //sets register[31] = 64'h0
        end

    always @ (negedge Clk)
        begin
            if(RegWr & RW != 5'b11111)
                begin    //If Registr Write = 1 and is not register[31]
                    registers[RW] <= #3 BusW;   //Write input to Register at RW
                end
        end
endmodule
