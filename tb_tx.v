`timescale 1ns/1ps
module tb_tx ();
reg [7:0] txData;
reg txStart;
reg rst;
reg clk;
wire txd;
wire clrTxStartBit;
wire enBaudClk, rstBaudClkCntr;
wire BaudClk;
initial
begin
clk=1'b1;
#9000 $finish;
end
  always
    begin
 #26 clk=~clk;
    end 
initial
begin
    rst=1'b0;
   #15 rst=~rst;
   #10 rst=~rst;
   #15 write_gen;
end 
task
write_gen;
@(posedge clk)
begin
txStart=1;
txData=8'd5;
end
endtask 
BaudClkGen  baud1(clk, rst, enBaudClk, rstBaudClkCntr, BaudClk);
uart_tx  uart_tx1(txData, txStart, BaudClk, clk, rst, txd, clrTxStartBit, enBaudClk,rstBaudClkCntr);
endmodule //tb_tx