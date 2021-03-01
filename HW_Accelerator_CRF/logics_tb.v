// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
/******************************************************************************
Project:            NLP Hardware Accelerator
Module:             PipelineRegister
Desciption:         Self verifying test bench for pipeline register

Created by Markus Bernal
*******************************************************************************/
`timescale 1ns / 1ps

`define HalfClockPeriod 5
`define STRLEN 45
`define ClockPeriod `HalfClockPeriod * 2

`include "pipelineRegister.v"
`include "logics.v"

module nodeLogicTest_v();

  reg[7:0]     watchdog, passed;
  initial
  begin
    $dumpfile("nodeLogic.vcd");
    $dumpvars;
  end

  // These tasks are used to check if a given test has passed and
  // confirm that all tests passed.
  task passNodeTest;
  input [1:0] actualNodeOut, expectedNodeOut;
  input [`STRLEN*8:0] testType;
  inout [7:0] 	  passed;

  if(actualNodeOut == expectedNodeOut)
      begin
      $display ("%s passed", testType);
      passed = passed + 1;
      end
  else
    begin
      $display ("%s failed: 0x%x should be 0x%x", testType, actualNodeOut, expectedNodeOut);
    end
  endtask

  task passSampleTest;
    input [1:0] actualNodeOut, expectedNodeOut;
    input [`STRLEN*8:0] testType;
    inout [7:0] 	  passed;

    if(actualNodeOut == expectedNodeOut)
        begin
        $display ("%s passed", testType);
        passed = passed + 1;
        end
    else
      begin
        $display ("%s failed: 0x%x should be 0x%x", testType, actualNodeOut, expectedNodeOut);
      end
    endtask

      //Notifies user if all tests have passed
      task allPassed;
          input [7:0] passed;
          input [7:0] numTests;

          if(passed == numTests) $display ("All tests passed");
          else $display("Some tests failed: %d of %d passed", passed, numTests);
    endtask

  //Declaring ports for nodeLogic1
  reg [127:0]    sampleDataIn;  //sample received from pipeline register Q2
  reg [31:0]     inData;        //Data received from SRAM
  reg             nodeIndex;
  wire            nodeIndexQ2;   //node index from pipeline register Q1
  wire            nodeIndexQ5;   //node index from pipeline register Q5
  wire[1:0]       nextNode;      //output of next node
  reg             clk;           //clock signal

  //Declaring variables for leafLogic
  reg [31:0]     multFactor;
  reg [31:0]     offsetFactor;
  reg [31:0]       featureIndex;
  wire[127:0]    sampleData_o;

  //Testing node logic with pipeline registers to verify delays
  //declaring registers and wires
  wire [127:0]   sampleQ2,    sampleQ3,    sampleQ4,    sampleQ5;
  wire            nodeIndexQ3, nodeIndexQ4;

  //connecting pipeline registers
  pipelineRegister1  q1(
    .sampleData_i(sampleDataIn),
    .nodeIndexIn(nodeIndex),
    .clk(clk),
    .nodeIndexOut(nodeIndexQ2),
    .sampleData_o(sampleQ2)
  );

  pipelineRegister1  q2(
    .sampleData_i(sampleQ2),
    .nodeIndexIn(nodeIndexQ2),
    .clk(clk),
    .nodeIndexOut(nodeIndexQ3),
    .sampleData_o(sampleQ3)
  );

  pipelineRegister1  q3(
    .sampleData_i(sampleQ3),
    .nodeIndexIn(nodeIndexQ3),
    .clk(clk),
    .nodeIndexOut(nodeIndexQ4),
    .sampleData_o(sampleQ4)
  );

  pipelineRegister1  q4(
    .sampleData_i(sampleQ4),
    .nodeIndexIn(nodeIndexQ4),
    .clk(clk),
    .nodeIndexOut(nodeIndexQ5),
    .sampleData_o(sampleQ5)
  );

  pipelineRegister1  q5(
    .sampleData_i(sampleQ5),
    .nodeIndexIn(nodeIndexQ2),
    .clk(clk),
    .nodeIndexOut(),
    .sampleData_o()
  );

  //Device Under Test
  nodeLogic1   dut(
    .sampleData_i(sampleDataIn),
    .nodeIndex(nodeIndexQ5),
    .clk(clk),
    .inData(inData),
    .nextNodeIndex(nextNode)
    );

  //Device Under Test
  leafLogic   dut2(
    .sampleData_i(sampleDataIn),
    .multipleFactor(multFactor),
    .offsetFactor(offsetFactor),
    .featureIndex(featureIndex),
    .clk(clk),
    .sampleData_o(sampleData_o)
    );

initial
begin
//monitor statement
//$monitor("time: %d, nodeQ2: %d, nodeQ5: %d, nextNode: %d, SampleDataIn: %d", $time, nodeIndexQ2, nodeIndexQ5, nextNode, sampleDataIn);

//initializing inputs
sampleDataIn = 0;
inData       = 0;
nodeIndex    = 0;
clk          = 0;

multFactor   = 0;
offsetFactor = 0;
featureIndex = 0;

//beginning test vectors
//************************************************************************

//node logic test
//Test 1: sample > threshold & node index = 0
#(1*`ClockPeriod);
inData       <= 128'h400;
sampleDataIn <= 2048'h8;

//Test 2: sample < threshold & node index = 0
#(1*`ClockPeriod);
inData       <= 128'h900;
sampleDataIn <= 2048'h4;

//Test 3: sample = threshold & node index = 0
#(1*`ClockPeriod);
inData       = 128'h800;
sampleDataIn = 2048'h8;

//Test 4: sample > threshold & node index = 1
#(1*`ClockPeriod);
nodeIndex    = 1;
inData       = 128'h400;
sampleDataIn = 2048'h8;

//Test 5: sample < threshold & node index = 1
#(1*`ClockPeriod);
inData       = 128'h800;
sampleDataIn = 2048'h4;

//Test 6: sample = threshold & node index = 1
#(1*`ClockPeriod);
inData       = 128'h800;
sampleDataIn = 2048'h8;

//Leaf logic tests
//Test 7: offset factor of 0
#(1*`ClockPeriod);
multFactor       = 128'h8;
sampleDataIn = 2048'h8;
featureIndex = 8'b0;
offsetFactor = 0;

//Test 8: offset factor of 5
#(1*`ClockPeriod);
multFactor       = 128'h8;
sampleDataIn = 2048'h8;
featureIndex = 8'b0;
offsetFactor = 5;

//***********************************************************************
end

initial
  begin
    //2 clock cycles
    #(5*`ClockPeriod);

    //test 1
    passNodeTest(nextNode, {2'b00}, "Test 1: sample > threshold & node index = 0", passed);

    //test 2
    #(1*`ClockPeriod);
    passNodeTest(nextNode, {2'b01}, "Test 2: sample < threshold & node index = 0", passed);

    //test 3
    #(1*`ClockPeriod);
    passNodeTest(nextNode, {2'b01}, "Test 3: sample = threshold & node index = 0", passed);

    //test 4
    #(1*`ClockPeriod);
    passNodeTest(nextNode, {2'b10}, "Test 4: sample > threshold & node index = 1", passed);

    //test 5
    #(1*`ClockPeriod);
    passNodeTest(nextNode, {2'b11}, "Test 5: sample < threshold & node index = 1", passed);

    //test 6
    #(1*`ClockPeriod);
    passNodeTest(nextNode, {2'b10}, "Test 6: sample = threshold & node index = 1", passed);

    #(1*`ClockPeriod);
    passSampleTest(sampleData_o, {2047'h40}, "Test 7: offset factor of 0", passed);

    #(1*`ClockPeriod);
    passSampleTest(sampleData_o, {2047'h45}, "Test 8: offset factor of 5", passed);

    $finish;
  end

  //Prevents simulation from running endlessly
  always @(*)
  begin
    if (watchdog == 16'hFF)
      begin
        $display("Watchdog Timer Expired.");
        $finish;
      end
  end

  always @(*)
    begin
      #`HalfClockPeriod clk <= ~clk;
      #`HalfClockPeriod clk <= ~clk;
      watchdog <= watchdog + 1;
    end
endmodule
