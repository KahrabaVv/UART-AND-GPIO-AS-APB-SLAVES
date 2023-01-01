 `timescale 1us/100ns
 module UART(padd, pdata, psel, pen, pwr, rst, clk, prdata, txStart, txData, rxStart, rxData,store, clrTxStartBit,clrRxStartBit,PREADY,PSTRB);
 input[31:0] padd,pdata;
 input psel,pen,pwr,rst,clk;
 input [12:0] rxData;
 input store, clrTxStartBit;
 input clrRxStartBit;
 output[31:0] prdata;
 output [7:0] txData;
 output txStart, rxStart;
 output reg PREADY;
 input [3:0]PSTRB;
 wire[3:0] n;
 reg[31:0] prdata;
 reg sel1,sel2;
 wire parity_rx;
 reg [12:0]config_rx_data; // Reciever Buffer register
 reg [7:0]config_tx_data ; // Transmitter Buffer register
 assign parity_rx = config_rx_data[10];
 reg txstart,rxstart;
integer i;
integer j=0;
always @(*)
    begin
         if(rst)
              PREADY = 0;
         else
	     if((psel && !pen && !pwr)||(psel && !pen && pwr))
	           begin PREADY = 0; end
	         
	     else if(psel && pen && !pwr)
	         begin  PREADY = 1;
                sel2=1'b1;
	         end

	     else if(psel && pen && pwr)
	     begin  PREADY = 1;
	           sel1=1'b1; end

         else PREADY = 0;
    end
always @(pdata)
begin
if (pdata)
txstart <= 1'b1;
end
always @(store)
begin
if(store)
config_rx_data<= rxData ;
else
begin
config_rx_data<= config_rx_data;
end
end
always @*
begin
case(padd)
 3'd0:
begin
if(sel1)
begin
for(i=0;i<32;i=i+1)
begin
    if(PSTRB[i/8]!=0&&j<8)
    begin
     config_tx_data[j]<= pdata[i];
     j=j+1;
    end
end
end
else
config_tx_data<= config_tx_data;
end
 3'd1:
begin
rxstart=1'b1;
if(sel2)
prdata<=config_rx_data[9:2]; // Reciever Buffer register
end

endcase
end
 always@*
 begin
if(clrTxStartBit)
txstart=1'b0;
if(clrRxStartBit)
rxstart=1'b0;
end
assign txStart = txstart;
assign rxStart = rxstart;
assign txData = config_tx_data;
endmodule
