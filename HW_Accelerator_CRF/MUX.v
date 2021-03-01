/*---------------------------------------------------------
Project:    NLP Hardware Accelerator
Module:     Mux
Desciption: Random Forest classifier is a deep learning
            algorithm that requires nodes

Created by Markus Bernal
-----------------------------------------------------------*/

module mux(
  //declaring ports
  input  [255:0]     d,     //input sample data
  input  [7:0]        sel,   //chooses sample data using feature index
  output reg [31:0]   y      //output feature = sample[feature index]
);


always @(d or sel)
begin
    case(sel)
        4'h0:  y <= d[15:0];
        4'h1:  y <= d[31:16];
        4'h2:  y <= d[47:32];
        4'h3:  y <= d[63:48];
        4'h4:  y <= d[79:64];
        4'h5:  y <= d[95:80];
        4'h6:  y <= d[111:96];
        4'h7:  y <= d[127:112];
        4'h8:  y <= d[143:128];
        4'h9:  y <= d[159:144];
        4'hA:  y <= d[175:160];
        4'hB:  y <= d[191:176];
        4'hC:  y <= d[207:192];
        4'hD:  y <= d[223:208];
        4'hE:  y <= d[239:224];
        4'hF:  y <= d[255:240];
    endcase
end
endmodule
