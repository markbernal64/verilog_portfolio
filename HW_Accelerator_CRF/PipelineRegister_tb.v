/******************************************************************************
Project:            NLP Hardware Accelerator
Module:             PipelineRegister
Desciption:         Self verifying test bench for pipeline register

Created by Markus Bernal
*******************************************************************************/
`timescale 1ns / 1ps

`define HalfClockPeriod 5
`define STRLEN 32
`define ClockPeriod `HalfClockPeriod * 2

`include "pipelineRegister.v"

module PipelineRegisterTest_v;

    reg[7:0]     watchdog, passed;
    initial
    begin
        $dumpfile("PipelineRegister.vcd");
        $dumpvars;
    end

    // These tasks are used to check if a given test has passed and
    // confirm that all tests passed.
    task passTest;
        input [31:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;
        inout [7:0] 	  passed;

        if(actualOut == expectedOut)
            begin
                $display ("%s passed", testType);
                passed = passed + 1;
            end
        else
            begin
                $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
            end
    endtask

    //Notifies user if all tests have passed
    task allPassed;
        input [7:0] passed;
        input [7:0] numTests;

        if(passed == numTests) $display ("All tests passed");
        else $display("Some tests failed: %d of %d passed", passed, numTests);
    endtask

    //Declaring inputs
    reg  [255:0]       inData;         //data being loaded into the PipelineRegister
    reg  [7:0]         nodeIndexIn;    //
    reg                clk;            //clock signal

    //Declaring outputs
    wire  [7:0]         nodeIndexOut;   //
    wire  [255:0]      outData;        //data beging pulled from the registers

    //Device Under Test
    pipelineRegisterLeaf #(.stage(8))
                          dut(
                          .sampleData_i( inData ),
                          .nodeIndexIn( nodeIndexIn ),
                          .clk( clk ),
                          .nodeIndexOut( nodeIndexOut ),
                          .sampleData_o( outData )
    );

    initial begin
    //initialize inputs
    inData      = 127'h0;
    nodeIndexIn = 7'h0;
    clk         = 0;

    //initialize watchdog timer
    watchdog = 0;

    //wait for global reset
    #(1 * `ClockPeriod);

    //Testing sample data
    //********************************************************
    //Test 1: verifying sample data and node index were initialized
    #(1*`ClockPeriod);
    passTest(outData, 127'h0, "Test 1 sample data", passed);

    //Test 2:
    inData      = 127'h300;
    #(1*`ClockPeriod);
    passTest(outData, 127'h300, "Test 2 sample data", passed);

    //Test 3:
    inData      = {32{4'hF}};
    #(1*`ClockPeriod);
    passTest(outData, {32{4'hF}}, "Test 3 sample data", passed);

    //Test 4:
    inData      = {16{8'hF0}};
    #(1*`ClockPeriod);
    passTest(outData, {16{8'hF0}}, "Test 4 sample data", passed);

    //Test 5:
    inData      = {2{16'h7382}};
    #(1*`ClockPeriod);
    passTest(outData, {2{16'h7382}}, "Test 5 sample data", passed);
    //********************************************************

    //Testing node index
    //********************************************************
    //Test 6
    nodeIndexIn = 7'h0;
    #(1*`ClockPeriod);
    passTest(nodeIndexOut, 7'h0, "Test 6  node index", passed);

    //Test 7
    nodeIndexIn = 7'h7;
    #(1*`ClockPeriod);
    passTest(nodeIndexOut, 7'h7, "Test 7  node index", passed);

    //Test 8
    nodeIndexIn = 7'h7;
    #(1*`ClockPeriod);
    passTest(nodeIndexOut, 7'h7, "Test 8  node index", passed);

    //Test 9
    nodeIndexIn = 7'h7;
    #(1*`ClockPeriod);
    passTest(nodeIndexOut, 7'h7, "Test 9  node index", passed);

    //Test 10
    nodeIndexIn = 7'h7;
    #(1*`ClockPeriod);
    passTest(nodeIndexOut, 7'h7, "Test 10 node index", passed);
    //********************************************************

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
