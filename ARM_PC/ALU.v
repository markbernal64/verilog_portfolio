`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111
`define MOVZ  4'b11??

module ALU(BusW, BusA, BusB, ALUCtrl, Zero);

    parameter n = 64;

    //declaring ports
    output  [n-1:0] BusW;
    input   [n-1:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    output  reg Zero;

    //internal variables
    reg     [n-1:0] BusW;

    //continuous block assignment
    always @(ALUCtrl or BusA or BusB or BusW) begin     //always run assignment if these values change

        casez (ALUCtrl)     //ALU opcode

            `AND: begin
                BusW <= #20 BusA & BusB;
                //$display("AND BusA: %h BusB: %h BusW: %h", BusA, BusB, BusW);
            end

            `OR: begin
                BusW <= #20 BusA | BusB;
                //$display("OR BusA: %h BusB: %h BusW: %h", BusA, BusB, BusW);
            end

            `ADD: begin
                BusW <= #20 BusA + BusB;
                //$display("ADD BusA: %h BusB: %h BusW: %h", BusA, BusB, BusW);
            end

            `SUB: begin
                BusW <= #20 BusA - BusB;
                //$display("SUB BusA: %h BusB: %h BusW: %h", BusA, BusB, BusW);
            end

            `PassB: begin
                BusW <= #20 BusB;
                //$display("PASSB BusA: %h BusB: %h BusW: %h", BusA, BusB, BusW);
            end

            `MOVZ:  begin
                BusW <= #20 BusB << (ALUCtrl[1:0]*16);
                //$display("MOVZ BusA: %h BusB: %h BusW: %h", BusA, BusB, BusW);
            end

        endcase

        Zero <= (BusW == 64'b0);
        //$display("Zero: %h BusW: %h", Zero, BusW);
    end
endmodule
