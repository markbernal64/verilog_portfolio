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
`define STRLEN 32
`define ClockPeriod `HalfClockPeriod * 2

`include "SRAM.v"


module SRAMTest_v;

    reg[7:0]     watchdog, passed;
    initial
    begin
        $dumpfile("SRAM.vcd");
        $dumpvars;
    end

    // These tasks are used to check if a given test has passed and
    // confirm that all tests passed.
    task passTest;
        input [127:0] actualOut, expectedOut;
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
    reg [31:0]      inData;        //data being loaded into SRAM
    reg              nodeIndex;    //
    reg              bCE;          //Cell enable
    reg              bWE;          //
    reg clk;

    //Declaring outputs
    wire [31:0]     outData;        //data beging pulled from the registers

    //Device Under Test
    SRAM #(1)        dut( .inData( inData ),
                          .nodeIndex( nodeIndex ),
                          .cellEnable( bCE ),
                          .writeEnable( bWE ),
                          .outData( outData )
    );

    initial begin
    //initialize inputs
    inData      = 31'h0;
    nodeIndex = 0;
    bCE         = 0;
    bWE         = 0;
    clk = 0;

    //initialize watchdog timer
    watchdog = 0;

    //wait for global reset
    #(1 * `ClockPeriod);

    //********************************************************
    //Test 1: testing wait function
    #(1*`ClockPeriod);
      passTest(outData, {32{1'bz}}, "Test 1: wait function ", passed);

    //Test 2: Testing writing function
    inData  = {32{4'hF}};
    bCE     = 1;
    bWE     = 1;

    #(1*`ClockPeriod);
    #(1*`ClockPeriod);

    //Test 3: Testing read function
    inData      = 32'hF;
    bCE         = 1;
    bWE         = 0;
    #(1*`ClockPeriod);
     passTest(outData, {32{4'hF}}, "Test 2: write function", passed);

    //********************************************************

    end


    //Prevents simulation from running endlessly
    always @(*)
    begin
        if (watchdog == 16'hF)
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
