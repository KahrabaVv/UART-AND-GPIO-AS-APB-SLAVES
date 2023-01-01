`timescale 1us/100ns
module uart_rx (rxStart, clk, rst, rxd, clrRxStartBit, store, rxData);
input rxd;
input rxStart;
input rst;
input clk;
output [12:0] rxData;
output clrRxStartBit;
output store;
wire rxShiftEn;
wire bitCountEn;
//wire count8en;
wire count16en;
reg [3:0] rxBitCount;
reg [3:0] count16;
//reg [2:0] count8;
reg [12:0] rxShiftReg;
reg[2:0] state,next_state;
reg flag=1'b0;
/////// Below code is for Receiver Shift Register /////////
always@(posedge clk or posedge rst)
begin
if(rst)
rxShiftReg<=13'h1FFF;
else if(rxShiftEn)
begin
rxShiftReg[12:0]<={rxd,rxShiftReg[12:1]};
flag=1'b1;
end
end
//////////////// Bit Counter Code /////////////////
always@(posedge clk or posedge rst)
begin
if(rst)
rxBitCount<=0;
else if (rxBitCount == 13)
rxBitCount<=0;
else if (bitCountEn)
rxBitCount<= rxBitCount + 1;
end
//////////////// wait for 15 Counter Code /////////////////
always@(posedge clk or posedge rst)
begin
if(rst)
 count16 <= 0;
else 
 count16 <= count16 + 1;
end
parameter
 s0 = 3'd0,
 s1 = 3'd1,
 s2 = 3'd2,
 s3 = 3'd3,
 s4 = 3'd4;
always@(posedge clk or posedge rst)
begin
if(rst)
state <=s0;
else
state <= next_state;
end
always@*
begin
next_state = 0;
case(state)
s0:
begin
if (rxStart&&rxd)
next_state = s1;
else
next_state = s0;
end
s1:
begin
if (count16 != 8)
next_state = s1;
else
next_state = s2;
end
s2:
begin
if (rxBitCount< 12)
next_state = s1;
else
next_state = s3;
end
s3:
begin
if (rxBitCount< 13)
next_state = s3;
else
next_state = s4;
end
s4:
next_state = s0;
endcase
end
//////// Control Signal Generation ////////////
assign count16en = (state == s1) ? 1:0;
assign bitCountEn = (state == s2 && flag) ? 1:0;
assign rxShiftEn = (state == s2) ? 1:0;
assign store = (state == s3) ? 1:0;
assign clrRxStartBit = (state == s4) ? 1:0;
assign rxData = rxShiftReg;
endmodule