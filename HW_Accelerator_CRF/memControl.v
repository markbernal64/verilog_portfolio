/******************************************************************************
Project:            NLP Hardware Accelerator
Module:             stage(1-8)
Desciption:         File contains modules for 8 stages

Created by Markus Bernal
*******************************************************************************/

`include "SRAM.v"

module memControl (
  input                 state,              //State of the memory
  input  [stage-1:0]    pipNodeIndex,       //node index from pipeline
  input                 clk,                //clk signal for synchronization
  input  [stage-1:0]    thresNodeIndex,     //node index from threshold
  input  [31:0]         thresData,          //data form threshold
  output reg [31:0]     outData             //Data read from registers
);

parameter stage = 1;

//declaring internal variables
reg CE, WE;                       //Cell enable and write enable for cat SRAM
reg [stage-1:0] nodeIndex;
wire [31:0] nodeData;  //Node Data read from SRAM


always @(*)
begin
  case(state)
    //write
    1'b0:
      begin
        CE <= 1;  WE <= 1;             //enable cat cellEnable and writeEnable
        nodeIndex <= thresNodeIndex;  //node address to write in sent to cat SRAM
      end

    //read
    1'b1:
      begin
        CE <= 1;  WE <= 0;             //disable cat cellEnable and writeEnable
        nodeIndex <= pipNodeIndex;  //node address to write in sent to ner SRAM
      end
  endcase
end

//Connecting categorizer SRAM
SRAM     #(
    .stage(stage)
    ) CATS(
  .inData(thresData),             //threshold/featureIndex loaded
  .nodeIndex(nodeIndex),       //address to find node specified
  .writeEnable(WE),            //categorizer write enable
  .cellEnable(CE),             //categorized cell enable
  .outData(nodeData)           //output data for reading
);

endmodule //MemoryControl

//***************************************************************************************************
module memControlLeaf (
  input                state,              //State of the memory
  input  [stage-1:0]   pipNodeIndex,     //node index from pipeline
  input  [stage-1:0]   thresNodeIndex,   //node index from threshold
  input                clk,                //clk signal for synchronization
  input  [31:0]        thresData,          //data form threshold
  output reg [31:0]    featureIndex,       //feature index read from SRAM
  output reg [31:0]    offsetFactor,       //offset factor read from SRAM
  output reg [31:0]    multipleFactor      //multiple factor read from SRAM

);

parameter stage = 8;


//declaring internal variables
reg CE, WE;                                           //Cell enable and write enable for cat SRAM
                                   //Cell enable and write enable for ner SRAM
reg [stage-1:0] nodeIndex;                   //address of node to be written or read
wire [31:0] nodeFeatureIndex;      //Node feature index read from SRAM
wire [31:0] nodeOffsetFactor;      //Node offset factor read from SRAM
wire [31:0] nodeMultipleFactor;  //Node multiple factor read from SRAM

always @(*)
begin
  case(state)
    //read
    1'b0:
      begin
        CE <= 1;  WE <= 0;                      //read SRAM
        nodeIndex <= pipNodeIndex;             //node address for ner
        featureIndex   <= nodeFeatureIndex;        //node feature index being sent to logic
        offsetFactor   <= nodeOffsetFactor;        //node offset factor being sent to logic
        multipleFactor <= nodeMultipleFactor;      //node multiple factor being sent to logic
      end

    //write
    1'b1:
      begin
        CE <= 1;  WE <= 1;                  //read cat SRAM
        nodeIndex <= thresNodeIndex;       //node address for ner
        featureIndex   <= nodeFeatureIndex;    //node feature index being sent to logic
        offsetFactor   <= nodeOffsetFactor;    //node offset factor being sent to logic
        multipleFactor <= nodeMultipleFactor;  //node multiple factor being sent to logic
      end
  endcase
end


//Connecting categorizer SRAM
leafSRAM #(
  .stage(8)
  )  CATS(
  .inData(thresData),                     //threshold/featureIndex loaded
  .nodeIndex(nodeIndex),           //address to find node specified
  .writeEnable(WE),                    //categorizer write enable
  .cellEnable(CE),                     //categorized cell enable
  .featureIndex(nodeFeatureIndex),     //feature index for reading
  .multipleFactor(nodeMultipleFactor), //multiple factor for reading
  .offsetFactor(nodeOffsetFactor)      //offset factor for reading
);
endmodule //MemoryControl
