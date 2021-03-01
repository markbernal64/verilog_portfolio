//sequantial logic positive edge triggered


/* LAB 6*/

module ccc(

    //declaring ports
    input clk, reset, throttle, set, accel, coast, cancel, resume, brake,

    output reg [7:0] speed, cruisespeed,
    output reg cruisecontrol
);

//connecting ports
wire clk, reset, throttle, set, accel, coast, cancel, resume, brake;

//This always block sets input conditions and their task
//statements execute on positive edge of the clock signal
always @(posedge clk) begin

        //initialize outputs
        if( reset ) begin

            speed <= 0;
            cruisespeed <= 0;
            cruisecontrol <= 0;
        end

        //set turns cruise control on and saves the vehicles cruisespeed
        //condition is that vehicle must be at a speed > 45mph to turn on cruisecontrol
        if( set and speed > 45) begin

            cruisecontrol <= 1;
            cruisespeed <= speed;
        end

        //accelerate raise cruisespeed by 1
        if( accel ) begin

            cruisespeed <= cruisespeed + 1;
        end

        //coast lowers cruisespped by 1
        if( coast ) begin

            cruisespeed <= cruisespeed - 1;
        end

        //turns off cruise control
        if( cancel ) begin

            cruisecontrol <= 0;
        end

        //continues cruise Control
        if( resume ) begin

            cruisecontrol <= 1;
        end

        //brake slows vehicle down and turns off cruisecontrol
        if( brake ) begin

            cruisecontrol <= 0;
            speed <= speed - 2;
        end

        //this block controls how speed will change if cruisecontrol is on
        if( cruisecontrol ) begin

            //if throttle is on increase speed
            if( throttle ) begin
                speed <= speed + 1;
            end

            //when throttle is off
            else begin

                //decrease speed if above set cruisespeed
                if( speed > cruisespeed ) begin
                    speed <= speed - 1;
                end

                //increase speed if below set cruisespeed
                else if( speed < cruisespeed ) begin
                    speed <= speed + 1;
                end

                //keep speed if it matches set cruisespeed
                else if( speed == cruisespeed ) begin
                    speed <= speed;
                end
            end
        end

        //this block controls how speed will change if cruisecontrol is off
        if( ~cruisecontrol ) begin

            //increase speed if throttle is on
            if( throttle ) begin
                speed <= speed + 1;
            end

            //decrease speed if throttle and brake are off
            else if( ~throttle & ~brake ) begin
                speed <= speed - 1;
            end
        end

end

endmodule
