

`include "trees.v"

module forest(
    input [255:0]   sampleData_i,
    input [7:0]     instruction,
    input [7:0]     thresNodeIndex,     //Change. Add everything to instruction instead
    input [31:0]    thresData,
    input           nodeIndex,
    input           clk,
    output [255:0]  decision1,
    output [255:0]  decision2,
    output [255:0]  decision3,
    output [255:0]  decision4,
    output [255:0]  decision5,
    output [255:0]  decision6,
    output [255:0]  decision7,
    output [255:0]  decision8
);

assign treeIndex = instruction[7:5];
assign opcode = instruction[4:0];

reg [4:0] opcode1, opcode2;
reg [4:0] opcode3, opcode4;
reg [4:0] opcode5, opcode6;
reg [4:0] opcode7, opcode8;

reg [7:0] thresNodeIndex1, thresNodeIndex2;
reg [7:0] thresNodeIndex3, thresNodeIndex4;
reg [7:0] thresNodeIndex5, thresNodeIndex6;
reg [7:0] thresNodeIndex7, thresNodeIndex8;

reg [31:0] thresData1, thresData2;
reg [31:0] thresData3, thresData4;
reg [31:0] thresData5, thresData6;
reg [31:0] thresData7, thresData8;
    
control_core ctrl(
    .startpc(startpc),
    .currentpc(currentpc),
    .dataout(dataout),
    .resetall(resetall),
    .CLK(clk)

tree t1(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode1),
    .thesNodeIndex(thresNodeIndex1),
    .thresholdData(thresData1),
    .decision(decision1)
);

tree t2(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode2),
    .thesNodeIndex(thresNodeIndex2),
    .thresholdData(thresData2),
    .decision(decision2)
);
tree t3(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode3),
    .thesNodeIndex(thresNodeIndex3),
    .thresholdData(thresData3),
    .decision(decision3)
);

tree t4(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode4),
    .thesNodeIndex(thresNodeIndex4),
    .thresholdData(thresData4),
    .decision(decision4)
);

tree t5(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode5),
    .thesNodeIndex(thresNodeIndex5),
    .thresholdData(thresData5),
    .decision(decision5)
);

tree t6(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode6),
    .thesNodeIndex(thresNodeIndex6),
    .thresholdData(thresData6),
    .decision(decision6)
);

tree t7(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode7),
    .thesNodeIndex(thresNodeIndex7),
    .thresholdData(thresData7),
    .decision(decision7)
);

tree t8(
    .sampleData_i(dataout),
    .nodeIndex(nodeIndex),
    .clk(clk),
    .opcode(opcode8),
    .thesNodeIndex(thresNodeIndex8),
    .thresholdData(thresData8),
    .decision(decision8)
);

always @(posedge clk)
begin
    case(treeIndex)
        3'b000:
          begin
              opcode1 <= opcode;
              thresData1 <= thresData;
              thresNodeIndex1 <= thresNodeIndex;
          end

        3'b001:
          begin
              opcode2 <= opcode;
              thresData2 <= thresData;
              thresNodeIndex2 <= thresNodeIndex;
          end

        3'b010:
          begin
              opcode3 <= opcode;
              thresData3 <= thresData;
              thresNodeIndex3 <= thresNodeIndex;
          end

        3'b011:
          begin
              opcode4 <= opcode;
              thresData4 <= thresData;
              thresNodeIndex4 <= thresNodeIndex;
          end

        3'b100:
          begin
              opcode5 <= opcode;
              thresData5 <= thresData1;
              thresNodeIndex5 <= thresNodeIndex;
          end

        3'b101:
          begin
              opcode6 <= opcode;
              thresData6 <= thresData1;
              thresNodeIndex6 <= thresNodeIndex;
          end

        3'b110:
          begin
              opcode7 <= opcode;
              thresData7 <= thresData1;
              thresNodeIndex7 <= thresNodeIndex;
          end

        3'b111:
          begin
              opcode8 <= opcode;
              thresData8 <= thresData1;
              thresNodeIndex8 <= thresNodeIndex;
          end
    endcase

end

endmodule
