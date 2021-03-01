//Testbench for cruise control
`include "cruise_control.v"


module CruiseControlTest_v;

    //creating output file
    initial begin
        $dumpfile("CruiseControlTest.vcd");
        $dumpvars;
    end

    //task determines if the test vector passes
    task passTest;

        input [7:0] actualOut, expectedOut;
        input [256:0] testType;
        inout [7:0] 	  passed;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    //task determines if all test vectors passed
    task allPassed;

        input [7:0] passed;
        input [7:0] numTests;

        if(passed == numTests) $display ("All tests passed");
        else $display("Some tests failed: %d of %d passed", passed, numTests);
    endtask

    //Testbench inputs
    reg [7:0]  passed;
    reg [15:0] watchdog;

    //Unit Under Test Inputs
    reg CLK, Reset, Throttle, Set, Accel, Coast, Cancel, Resume, Brake;

    //Outputs
    wire [7:0] Speed, Cruisespeed;
    wire CruiseControl;

    //Instantiate the Unit Under Test (UUT)
    ccc uut(
        .clk( CLK ),
        .reset( Reset ),
        .throttle( Throttle ),
        .set( Set ),
        .accel( Accel ),
        .coast( Coast ),
        .cancel( Cancel ),
        .resume( Resume ),
        .brake( Brake ),
        .speed( Speed ),
        .cruisespeed( Cruisespeed ),
        .cruisecontrol( CruiseControl )
    );

    initial begin

        //initialize Inputs
        Reset = 0;
        Throttle = 0;
        Set = 0;
        Accel = 0;
        Coast = 0;
        Cancel = 0;
        Resume = 0;
        Brake = 0;

        //apply reset signal using reset
        Reset = 1;              passTest(Reset, 7'b1, "reset on", passed);
        #10  Reset = 0;         passTest(Reset, 7'b0, "reset off", passed);

        //verify reset output
        passTest(Speed, 7'd0, "initialize speed", passed);
        passTest(Cruisespeed, 7'd0, "initialize cruisespeed", passed);

        //apply throttle signal to increase speed
        #10 Throttle = 1;       passTest(Throttle, 7'b1, "apply throttle", passed);

        //increase speed to 30mph
        #300;                   passTest(Speed, 7'd30, "increase speed to 30mph", passed);


        //try to set CruiseControl
        set = 1;                passTest(Set, 7'b1, "set signal on", passed);
        #5 Set = 0;             passTest(Set, 7'b0, "set signal off", passed);

        //verify CruiseControl is off
        passTest(CruiseControl, 7'b0, "cruise control fail test", passed);

        //Turn off throttle
        #5 Throttle = 0;        passTest(Throttle, 7'b0, "throttle off", passed);

        //Turn on when speed is 20
        #100 Throttle = 1;      passTest(Speed, 7'd20,"decrease speed to 20mph", passed);

        //Increase speed to 50mph
        #300;

        //set cruise control on
        Set = 1;                passTest(Set, 7'b1, "set signal on", passed);
        #10 Set = 0;            passTest(Set, 7'b0, "set signal off", passed);

        //verify CruiseControl is on
        passTest(CruiseControl, 7'b1, "cruise control on", passed);

        //release throttle when speed is 60mph
        #90 Throttle = 0;       passTest(Speed, 7'd60,"speed 60mph", passed);
                                passTest(Cruisespeed, 7'd50, "cruisespeed 50mph", passed);

        //apply brakes to turn off cruise control
        Brake = 1;
        #10 Brake = 0;          passTest(CruiseControl,7'b0, "cruise control off", passed);
                                passTest(Speed, 7'd58, "speed decrease by 2mph", passed);

        //apply resume when speed is at 30
        #280 Resume = 1;        passTest(Resume, 7'b1, "resume signal on", passed);
        #10 Resume = 0;

        //speed up to 50mph and cruise for 5 cycles
        #240;                   passTest(Speed, 7'd50, "cruise 50 mph: 1", passed);

        //apply accelerate for 5 pulses
        Accel = 1;              passTest(Accel, 7'b1, "accelerate on", passed);
        #50                     passTest(Accel, 7'b1, "accelerate 5 pulses", passed);
        Accel = 0;

        //coast for 5 clk cycles then give 5 coast signals
        #50                     passTest(Speed, 7'd55, "coast 55mph", passed);
        Coast = 1;              passTest(Coast, 7'b1, "coast on", passed);
        #50 Coast = 0;          passTest(Coast, 7'b0, "coast 5 pulses", passed);

        //coast for 5 cycles then send cancel signal
        #50 Cancel = 1;         passTest(Cancel, 7'b1, "cancel on", passed);
        #10 Cancel = 0;         passTest(Cancel, 7'b0, "cancel off", passed);

        #600;

        //Verify cancel parameters
        passTest(Speed, 7'd0, "speed 0mph", passed);
        passTest(Cruisespeed, 7'd0, "cruise speed 0mph", passed);
        passTest(CruiseControl, 7'b0, "cruise control off", passed);

        allPassed(passed, 30);
        $finish;
    end

    //initializes clock cycle to 0
    initial begin
        CLK = 0;
        watchdog = 0;
        passed = 0;
        allPassed = 0;
    end

    //this block controls clock signal
    //I chose a period of 10ns because it is easier to calculate cycles
    always begin
        #5 CLK = ~CLK;
    end

    // Kills the simulation if the watchdog is too high
    always @(*) begin

        if (watchdog == 16'hFFFF) begin
            $display("Watchdog Timer Expired.");
            $finish;
        end
    end

    endmodule
