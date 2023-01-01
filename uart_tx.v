`timescale 1us/100ns
module uart_tx (txData, txStart, BaudClk, clk, rst, txd, clrTxStartBit, enBaudClk,rstBaudClkCntr);
input [7:0] txData;
input txStart;
input BaudClk;
input rst;
input clk;
output txd;
output clrTxStartBit;
output enBaudClk, rstBaudClkCntr;
wire load;
wire txShiftEn;
wire bitCountEn;
wire parityBit;
reg [3:0] bitCount;
reg [12:0] txShiftReg;
reg[1:0] state,next_state;
assign parityBit = txData[0] ^ txData[1] ^ txData[2] ^ txData[3] ^ txData[4] ^ txData[5] ^
txData[6] ^ txData[7];
always@(posedge BaudClk or posedge rst)
begin
if(rst)
txShiftReg<=13'h1FFF;
else if(load)
begin
txShiftReg[1:0] <=2'b01;
txShiftReg[9:2] <=txData;
txShiftReg[10] <= parityBit;
txShiftReg[12:11] <=2'b10;
end
else if(txShiftEn)
txShiftReg[11:0]<=txShiftReg[12:1];
end
assign txd = txShiftReg[0];
always@(posedge BaudClk or posedge rst)
begin
if(rst)
bitCount<=0;
else if (bitCount == 14)
bitCount<=0;
else if (bitCountEn)
bitCount<= bitCount + 1;
end
parameter
 IDLE = 2'd0, LOAD = 2'd1,
 TRANSMITANDSHIFT = 2'd2,
 TX_DONE = 2'd3;
always@(posedge clk or posedge rst)
begin
if(rst)
state<=IDLE;
else
state = next_state;
end
always@*
begin
next_state = 0;
case(state)
IDLE:
begin
if (txStart&& ~BaudClk)
next_state = LOAD;
else
next_state = IDLE;
end
LOAD:
begin
if (BaudClk)
next_state = TRANSMITANDSHIFT;
else
next_state = LOAD;
end
TRANSMITANDSHIFT:
begin
    if (bitCount == 12)
next_state = TX_DONE;
else
next_state = TRANSMITANDSHIFT;
end
TX_DONE:
next_state = IDLE;
endcase
end
//////// Control Signal Generation ////////////
assign load = (state == LOAD)?1:0;
assign clrTxStartBit = (state == TX_DONE)?1:0;
assign txShiftEn = (state == TRANSMITANDSHIFT)?1:0;
assign bitCountEn = (state == TRANSMITANDSHIFT)?1:0;
assign enBaudClk = ((state == LOAD) || (state == TRANSMITANDSHIFT)) ?1:0;
assign rstBaudClkCntr = (state == TX_DONE)?1:0;
endmodule