// Code your design here
/*****************************************************************************
Project:            NLP Hardware Accelerator
Module:             PipelineRegister.v
Desciption:         Random Forest classifier is a deep learning
                    algorithm that requires nodes

Created by Markus Bernal
****************************************************************************/

module pipelineRegister (
    //Declaring ports
    input  [255:0]       sampleData_i,  //data being loaded into the PipelineRegister
    input  [stage-1:0]   nodeIndexIn,   //Node Index going into the register
    input                clk,           //clock signal
    output reg [stage-1:0] nodeIndexOut,  //Node index going out of the register
    output reg [255:0]   sampleData_o   //data beging pulled from the registers
);

parameter stage = 1;

//input data
always @(posedge clk)
  begin
    //register saves input
    sampleData_o  <= sampleData_i;
    nodeIndexOut  <= nodeIndexIn;
  end
endmodule // PipelineRegister

module pipelineRegisterNext(
      //Declaring ports
      input  [255:0]       sampleData_i,  //data being loaded into the PipelineRegister
      input  [stage-1:0]   nodeIndexIn,   //Node Index going into the register
      input                clk,           //clock signal
      output reg [stage:0] nodeIndexOut,  //Node index going out of the register
      output reg [255:0]   sampleData_o   //data beging pulled from the registers
  );

parameter stage = 8;

//input data
always @(posedge clk)
  begin
    //register saves input
    sampleData_o  <= sampleData_i;
    nodeIndexOut  <= nodeIndexIn;
  end
endmodule
