`timescale 1ns/1ps
module BaudClkGen (clk, rst, enBaudClk, rstBaudClkCntr, BaudClk);
input clk;
input rst;
input enBaudClk;
input rstBaudClkCntr;
output BaudClk;
reg [3:0] counter;
always @ (posedge clk or posedge rst)
begin
if (rst)
counter<= 0;
else if (rstBaudClkCntr)
counter<= 0;
else if (enBaudClk)
counter <= counter + 1;
end
assign BaudClk = (counter < 8) ? 0:1;
endmodule