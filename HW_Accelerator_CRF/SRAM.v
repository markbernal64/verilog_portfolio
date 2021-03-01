/*--------------------------------------------------------------------------------
Project:    NLP Hardware Accelerator
Module:     Asynchronous SRAM
Desciption: SRAM will be used to store text categorization threshold values as
            well as named entity recognition threshold values

Created by Markus Bernal
-----------------------------------------------------------------------------------*/
module SRAM(
    //Declaring ports
    input  [31:0]      inData,         //Data writen in node during training
    input  [stage-1:0] nodeIndex,      //Index of requested node
    input              cellEnable,     //Cell select enable
    input              writeEnable,    //Write enable
    output reg [31:0]  outData         //outputs data to stage to be decoded
);

//For each stage S, there are 2^S-1 registers
//Our Compact Random Forest classifier will have 5 stages.
parameter stage = 1;

//Internal NodeArray
reg [31:0] NodeArray [stage-1:0]; //128 bit by 2^S-1 register

//Read function
always @(cellEnable or writeEnable or nodeIndex)
  begin
    //device on and write function is disabled
    if (cellEnable && ~writeEnable)
      begin
        //select node from array using address and assign bits to it
        outData = NodeArray[nodeIndex];
      end

    else if(~cellEnable)
      begin
        //device is off, does not read
        outData  = {32{1'bz}};
      end
    end

//Write function
always @(cellEnable or writeEnable or nodeIndex)
  begin
    //device on; write enabled
    if(cellEnable && writeEnable)
      begin
        //output at node address
        NodeArray[ nodeIndex ] = inData;
      end

    else if(~cellEnable)
      begin
        //device is off, does not write
        outData = {32{1'bz}};
      end
  end
endmodule // NodeVariables

module leafSRAM (
    //Declaring ports
    input  [31:0]      inData,           //Data writen in node during training
    input  [stage-1:0] nodeIndex,        //Index of requested node
    input              cellEnable,       //Cell select enable
    input              writeEnable,      //Write enable
    output reg [31:0]  featureIndex,     //outputs feature index to leaf stage
    output reg [31:0]  multipleFactor,   //outputs multiplication factor to leaf logic
    output reg [31:0]  offsetFactor      //outputs offset factor to leaf logic
);

//For each stage S, there are 2^S-1 registers
//Our Compact Random Forest classifier will have 5 stages.
parameter stage = 8;

//Internal NodeArray
reg [127:0] NodeArray [stage-1:0]; //128 bit by 2^S-1 register

//Read function
always @(cellEnable or writeEnable or nodeIndex)
  begin
    //device on and write function is disabled
    if (cellEnable && ~writeEnable)
      begin
        //select node from array using address and assign bits to it
        featureIndex   <= NodeArray[nodeIndex];
        offsetFactor   <= NodeArray[nodeIndex + 1];
        multipleFactor <= NodeArray[nodeIndex + 2];
      end

    else if(~cellEnable)
      begin
        //device is off, does not read
        featureIndex   <= {32{1'bz}};
        offsetFactor   <= {32{1'bz}};
        multipleFactor <= {32{1'bz}};
      end
    end

//Write function
always @(cellEnable or writeEnable or nodeIndex)
  begin
    //device on; write enabled
    if(cellEnable && writeEnable)
      begin
        //output at node address
        NodeArray[ nodeIndex ][31:0] = inData;
      end

    else if(~cellEnable)
      begin
        //device is off, does not write
        featureIndex   <= {32{1'bz}};
        offsetFactor   <= {32{1'bz}};
        multipleFactor <= {32{1'bz}};
      end
  end
endmodule //SRAM
