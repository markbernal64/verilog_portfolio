module SRAM (Address, InData, OutData, bCE, bWE);

parameter AddressSize = 18;		// 2^18 = 256K
parameter WordSize = 8;			// 8 bits

// Port Declaration
input bCE, bWE;
input [AddressSize-1:0]		Address;
input [WordSize-1:0]		InData;
output [WordSize-1:0]		OutData;

// Internal Variable
reg [WordSize-1:0] OutData;
reg [WordSize-1:0] DataArray[63:0];	//Creates array to store memory

// Function Write
always @(bCE or bWE or Address)
begin
	if(~bCE && ~bWE)
	begin
	DataArray[Address] = InData;  //write data into DataArray
	end
end

// Function Read
always @(bCE or bWE or Address or InData)
begin
	if(~bCE && bWE)
	begin
	OutData = DataArray[Address]; //when bCE is low active and bWE is high, it is reading operation
	end
	
	else if (bCE)
	begin
	OutData = 8'bz; //device is off, and does not read
	end

end

endmodule

