/******************************************************************************
Project:            NLP Hardware Accelerator
Module:             cell(1-8)
Desciption:         File contains modules for 7 cell stages and 1 leaf stage

Created by Markus Bernal
*******************************************************************************/

`include "pipelineRegister.v"
`include "logics.v"
`include "memControl.v"

module cells(
    input                state,
    input [31:0]         thresData,
    input [stage-1:0]    thresNodeIndex,
    input [255:0]        sampleData_i,
    input [stage-1:0]    nodeIndexIn,
    input                clk,
    output[255:0]        sampleData_o,
    output[stage:0]      nextNodeIndex
);

parameter stage = 1;

wire [stage-1:0] nodeQ1toQ2;
wire [stage-1:0] nodeQ2toQ3;
wire [stage-1:0] nodeQ3toQ4;
wire [stage-1:0] nodeQ4toLogic;

wire [1:0]   nodeLogictoRegister;
wire [31:0]  memtologic;
wire [255:0] sampleQ1toQ2;
wire [255:0] sampleQ2toQ3;
wire [255:0] sampleQ3toQ4;
wire [255:0] sampleQ4toLogic;
wire [255:0] sampleLogictoRegister;

pipelineRegister #(
    .stage(stage)
    ) q1(
    .sampleData_i(sampleData_i),
    .nodeIndexIn(nodeIndexIn),
    .clk(clk),
    .nodeIndexOut(nodeQ1toQ2),
    .sampleData_o(sampleData_o)
  );

pipelineRegister #(
    .stage(stage)
    ) q2(
    .sampleData_i(sampleQ1toQ2),
    .nodeIndexIn(nodeQ1toQ2),
    .clk(clk),
    .nodeIndexOut(nodeQ2toQ3),
    .sampleData_o(sampleQ2toQ3)
  );

pipelineRegister #(
    .stage(stage)
    ) q3(
    .sampleData_i(sampleQ2toQ3),
    .nodeIndexIn(nodeQ2toQ3),
    .clk(clk),
    .nodeIndexOut(nodeQ3toQ4),
    .sampleData_o(sampleQ3toQ4)
  );
pipelineRegister #(
    .stage(stage)
    ) q4(
    .sampleData_i(sampleQ3toQ4),
    .nodeIndexIn(nodeQ3toQ4),
    .clk(clk),
    .nodeIndexOut(nodeQ4toLogic),
    .sampleData_o(sampleQ4toLogic)
  );

pipelineRegister #(
    .stage(stage+1)
    ) q5(
    .sampleData_i(sampleLogictoRegister),
    .nodeIndexIn(nodeLogictoRegister),
    .clk(clk),
    .nodeIndexOut(nextNodeIndex),
    .sampleData_o(sampleData_o)
  );

nodeLogic#(
    .stage(stage)
    ) nl1(
    .sampleData_i(sampleQ4toLogic),
    .nodeIndex(nodeQ4toLogic),
    .clk(clk),
    .inData(memtologic),
    .nextNodeIndex(nodeLogictoRegister),
    .sampleData_o(sampleLogictoRegister)
  );

memControl #(
    .stage(stage)
    ) mc1(
    .state(state),
    .pipNodeIndex(nodeQ2toQ3),
    .clk(clk),
    .thresNodeIndex(thresNodeIndex),
    .thresData(thresData),
    .outData(memtologic)
  );
endmodule

module leaf(
  input                 state,
  input [31:0]          thresData,
  input [stage-1:0]     thresNodeIndex,
  input [255:0]         sampleData_i,
  input [stage-1:0]     nodeIndexIn,
  input                 clk,
  output[255:0]         sampleData_o
);

parameter stage = 8;

wire [stage-1:0]    registerQ1toQ2;
wire [stage-1:0]    registerQ2toSRAM;
wire [255:0] sampleQ1toQ2;
wire [255:0] sampleQ2toLogic;

pipelineRegister#(
    .stage(stage)
    ) q1(
  .sampleData_i(sampleData_i),
  .nodeIndexIn(nodeIndexIn),
  .clk(clk),
  .nodeIndexOut(registerQ1toQ2),
  .sampleData_o(sampleQ1toQ2)
);

pipelineRegister #(
    .stage(stage)
    ) q2(
  .sampleData_i(sampleData_i),
  .nodeIndexIn(nodeIndexIn),
  .clk(clk),
  .nodeIndexOut(registerQ2toSRAM),
  .sampleData_o(sampleQ2toLogic)
);

wire [31:0] featureIndextoLogic;
wire [31:0] offsetFactortoLogic;
wire [31:0] multipleFactortoLogic;

leafLogic ll(
   .sampleData_i(sampleQ2toLogic),
   .multipleFactor(multipleFactortoLogic),
   .offsetFactor(offsetFactortoLogic),
   .featureIndex(featureIndextoLogic),
   .clk(clk),
   .decision(sampleData_o)
);

memControlLeaf #(
    .stage(stage)
    ) mc8(
   .state(state),
   .pipNodeIndex(registerQ2toSRAM),
   .thresNodeIndex(thresNodeIndex),
   .clk(clk),
   .thresData(thresData),
   .featureIndex(featureIndextoLogic),
   .offsetFactor(offsetFactortoLogic),
   .multipleFactor(multipleFactortoLogic)
);
endmodule
