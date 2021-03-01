/******************************************************************************
Project:            NLP Hardware Accelerator
Module:             PipelineRegister
Desciption:         Self verifying test bench for pipeline register

Created by Markus Bernal
*******************************************************************************/

`include "cells.v"

module tree(
    input [255:0] sampleData_i,
    input         nodeIndex,
    input         clk,
    input [4:0]   opcode,
    input [7:0]   thesNodeIndex,
    input [31:0]  thresholdData,
    output [255:0] decision
);

assign state = opcode[1:0];
assign depth = opcode[4:2];

reg [1:0] state1, state2, state3, state4;
reg [1:0] state5, state6, state7, state8;

reg       thresNodeIndex1;
reg [1:0] thresNodeIndex2;
reg [2:0] thresNodeIndex3;
reg [3:0] thresNodeIndex4;
reg [4:0] thresNodeIndex5;
reg [5:0] thresNodeIndex6;
reg [6:0] thresNodeIndex7;
reg [7:0] thresNodeIndex8;
reg [7:0] thresNodeIndex;

reg [31:0] thresholdData1, thresholdData2;
reg [31:0] thresholdData3, thresholdData4;
reg [31:0] thresholdData5, thresholdData6;
reg [31:0] thresholdData7, thresholdData8;

wire [255:0] sampleDataC1toC2, sampleDataC2toC3;
wire [255:0] sampleDataC3toC4, sampleDataC4toC5;
wire [255:0] sampleDataC5toC6, sampleDataC6toC7;
wire [255:0] sampleDataC7toLeaf, decision;

wire [1:0] nextNodeIndexC1toC2;
wire [2:0] nextNodeIndexC2toC3;
wire [3:0] nextNodeIndexC3toC4;
wire [4:0] nextNodeIndexC4toC5;
wire [5:0] nextNodeIndexC5toC6;
wire [6:0] nextNodeIndexC6toC7;
wire [7:0] nextNodeIndexC7toLeaf;

cells #(
  .stage(1)
  )   c1(
  .state(state1),
  .thresData(thresholdData1),
  .thresNodeIndex(thresNodeIndex1),
  .sampleData_i(sampleData_i),
  .nodeIndexIn(nodeIndex),
  .clk(clk),
  .sampleData_o(sampleDataC1toC2),
  .nextNodeIndex(nextNodeIndexC1toC2)
);

cells #(
  .stage(2)
  )   c2(
  .state(state2),
  .thresData(thresholdData2),
  .thresNodeIndex(thresNodeIndex2),
  .sampleData_i(sampleDataC1toC2),
  .nodeIndexIn(nextNodeIndexC1toC2),
  .clk(clk),
  .sampleData_o(sampleDataC2toC3),
  .nextNodeIndex(nextNodeIndexC2toC3)
  );

cells #(
  .stage(3)
  )   c3(
  .state(state3),
  .thresData(thresholdData3),
  .thresNodeIndex(thresNodeIndex3),
  .sampleData_i(sampleDataC2toC3),
  .nodeIndexIn(nextNodeIndexC2toC3),
  .clk(clk),
  .sampleData_o(sampleDataC3toC4),
  .nextNodeIndex(nextNodeIndexC3toC4)
  );

cells #(
  .stage(4)
  )   c4(
  .state(state4),
  .thresData(thresholdData4),
  .thresNodeIndex(thresNodeIndex4),
  .sampleData_i(sampleDataC3toC4),
  .nodeIndexIn(nextNodeIndexC3toC4),
  .clk(clk),
  .sampleData_o(sampleDataC4toC5),
  .nextNodeIndex(nextNodeIndexC4toC5)
  );

cells #(
  .stage(5)
  )   c5(
  .state(state5),
  .thresData(thresholdData5),
  .thresNodeIndex(thresNodeIndex5),
  .sampleData_i(sampleDataC4toC5),
  .nodeIndexIn(nextNodeIndexC4toC5),
  .clk(clk),
  .sampleData_o(sampleDataC5toC6),
  .nextNodeIndex(nextNodeIndexC5toC6)
  );

cells #(
  .stage(6)
  )   c6(
  .state(state6),
  .thresData(thresholdData6),
  .thresNodeIndex(thresNodeIndex6),
  .sampleData_i(sampleDataC5toC6),
  .nodeIndexIn(nextNodeIndexC5toC6),
  .clk(clk),
  .sampleData_o(sampleDataC6toC7),
  .nextNodeIndex(nextNodeIndexC6toC7)
  );

cells #(
  .stage(7)
  )   c7(
  .state(state7),
  .thresData(thresholdData7),
  .thresNodeIndex(thresNodeIndex7),
  .sampleData_i(sampleDataC6toC7),
  .nodeIndexIn(nextNodeIndexC6toC7),
  .clk(clk),
  .sampleData_o(sampleDataC7toLeaf),
  .nextNodeIndex(nextNodeIndexC7toLeaf)
  );

leaf #(
  .stage(8)
  )   leaf(
  .state(state8),
  .thresData(thresholdData8),
  .thresNodeIndex(thresNodeIndex8),
  .sampleData_i(sampleDataC7toLeaf),
  .nodeIndexIn(nextNodeIndexC7toLeaf),
  .clk(clk),
  .sampleData_o(decision)
  );

always @(depth or state) begin
    case(depth)
      3'b000:
          begin
            state1 <= state;
            thresNodeIndex1 <= thresNodeIndex[0];
          end
      3'b001:
          begin
            state2 <= state;
            thresNodeIndex2 <= thresNodeIndex[1:0];
          end
      3'b010:
          begin
            state3 <= state;
            thresNodeIndex3 <= thresNodeIndex[2:0];
          end
      3'b011:
          begin
            state4 <= state;
            thresNodeIndex4 <= thresNodeIndex[3:0];
          end
      3'b100:
          begin
            state5 <= state;
            thresNodeIndex5 <= thresNodeIndex[4:0];
          end
      3'b101:
          begin
            state6 <= state;
            thresNodeIndex6 <= thresNodeIndex[5:0];
          end
      3'b110:
          begin
            state7 <= state;
            thresNodeIndex7 <= thresNodeIndex[6:0];
          end
      3'b111:
          begin
            state8 <= state;
            thresNodeIndex8 <= thresNodeIndex[7:0];
          end
    endcase
end
endmodule
