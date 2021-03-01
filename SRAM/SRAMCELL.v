module SRAMCELL (InData, OutData, bCS, bWE);

// Declare input/output signals
input bCS, bWE, InData;
output OutData;

// Internal register/wire
reg AND1, AND2, DLATCH, OutData;

// Functional Module Description
always @(*)	// Sensitivity
begin
	AND1 = InData & ~bWE;		//describes 1st AND gate
	AND2 = OutData & bWE;		//describes 2nd AND gate
	DLATCH = ~(~AND1 & ~AND2);	//descrives input to dlatch
	
	if (~bCS)
	begin
		OutData = DLATCH;
	end
	
	else if (bCS && InData == 1'b0)
	begin
		OutData = 1'b0;
	end
	
	else if (bCS && InData == 1'bx) 
	begin
		OutData = 1'bx;
	end
end
endmodule

