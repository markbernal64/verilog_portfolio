// Module Definition
module Datapath_Unit (
	Serial_out,
	BC_lt_BCmax,
	Data_Bus,
	Load_XMT_DR,
	Load_XMT_shftreg,
	start,
	shift,
	clear,
	Clock,
	rst_b);

	// Declare internal parameters
	parameter		word_size = 8;
	parameter		size_bit_count = 3;
	parameter		all_ones = {(word_size + 1){1'b1}};	// 9 bits of ones

	// Declare input/output
	output		Serial_out;
	output		BC_lt_BCmax;

	input [word_size-1:0]	Data_Bus;
	input			Load_XMT_DR;
	input			Load_XMT_shftreg;
	input			start;
	input			shift;
	input			clear;
	input 		Clock;
	input			rst_b;

	// Declare internal reg variable
	reg [word_size-1:0]	XMT_datareg;	// Transmit Data Register
	reg [word_size:0]		XMT_shftreg;	// Transmit Shift Register:{data, start bit}
	reg [size_bit_count:0]	bit_count;		// Counts the bits that are transmitted

	assign Serial_out = XMT_shftreg[0];
	assign BC_lt_BCmax = (bit_count < word_size +1);

	// Connect your UDP (User Defined Primitive)
	/*UDP_BCmax BCmax1(BC_lt_BCmax, bit_count[3], bit_count[2], bit_count[1], bit_count[0]);*/

	// Data Path for UART Transmitter
	always @(posedge Clock or negedge rst_b)
	begin
		// -----------------------------------
		if(~rst_b)
			begin
			bit_count <= 0;
			XMT_shftreg <= all_ones;
			XMT_datareg <= 8'b11111111;
			end

		else
			begin
			if (Load_XMT_DR)
				begin
				XMT_datareg <= Data_Bus;
				end

			else
				begin
				XMT_datareg <= XMT_datareg;
				end

			if(start)
				begin
				XMT_shftreg[0] <= 1'b0;
				end

			else if(Load_XMT_shftreg)
				begin
				XMT_shftreg <= {XMT_datareg[7:0], 1'b1};
				end

			else if(shift)
				begin
				XMT_shftreg <= {1'b1, XMT_shftreg[8:1]};
				end

			else
				begin
				XMT_shftreg <= XMT_shftreg;
				end

			if(clear)
				begin
				bit_count <= 4'b0000;
				end

			else if(shift)
				begin
				bit_count <= (bit_count +1);
				end
			else
				begin
				bit_count <= bit_count;
				end

			end
		// -----------------------------------
	end
endmodule
