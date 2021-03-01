// Code your design here
/********************************************************************
Project:    NLP Hardware Accelerator
Module:     NodeLogic Stage 1
Desciption: Random Forest classifier is a deep learning
            algorithm that requires nodes

Created by Markus Bernal
**********************************************************************/
`include "MUX.v"

module nodeLogic(
  //declaring ports
  input  [255:0]     sampleData_i,      //Sample data set into stage
  input  [stage-1:0] nodeIndex,         //node index for stage
  input				       clk,               //clock signal used for output
  input  [31:0]      inData,            //data received from SRAM
  output reg [1:0]   nextNodeIndex,     //node index for next stage
  output reg [255:0] sampleData_o
);

parameter stage = 1;

//declairng internal variables
wire [31:0] threshold;                  //threshold is compared to feature for T or F
wire [31:0] feature;                    //feature is compared to threshold for T or F
wire [7:0]  featureIndex;               //Feature index is connect to a mux to extract


//decoding input data
assign featureIndex  = inData[7:0];     //extracting feature index from inData
assign threshold     = inData[31:8];   //extracting threshold from inData

//connecting mux to sample data
mux M1(sampleData_i, featureIndex, feature);

//SRAM
always@(posedge clk)
  begin
    //assign split node logic for the ouput
    nextNodeIndex <= (feature < threshold) + (nodeIndex << 1);
    sampleData_o  <= sampleData_i;
  end
endmodule // TreeStage

//**********************************************************************
//Final stage in the Compact Random Forest
module leafLogic(
    //declaring ports
    input  [255:0]     sampleData_i,   //Sample data set into the stage
    input  [31:0]      multipleFactor,     //a multiplication factor is used
    input  [31:0]      offsetFactor,   //offset factor used in logic
    input  [31:0]      featureIndex,
    input              clk,
    output [255:0]     decision
);
    //declaring internal variables
    wire [7:0]  nodeFeatureIndex = featureIndex[7:0];
    wire [31:0]  feature;
    reg  [31:0]  B;
    reg  [255:0] decision;

    //connecting mux
    mux M1(sampleData_i, nodeFeatureIndex, feature);

    always @(posedge clk)
    begin
        //logic
        B <= (multipleFactor * feature);
        decision <= (offsetFactor + B);
    end
endmodule
