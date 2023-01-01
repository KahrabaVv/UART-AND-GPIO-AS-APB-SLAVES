`timescale 1us/100ns
module apbUART (padd, pdata, psel, pen, pwr, rst, clk, prdata, txd, rxd,PSTRB);
input[31:0] padd,pdata;
input psel,pen,pwr,rst,clk;
input rxd;
output[31:0] prdata;
output txd;
input [3:0]PSTRB;
wire [7:0] txData;
wire [12:0] rxData;
wire enBaudClk, rstBaudClkCntr, BaudClk;
wire txStart;
wire tx_rx_short;
wire rxStart, store;
wire PREADY;

UART APB1(padd, pdata, psel, pen, pwr, rst, clk, prdata, txStart, txData, rxStart, rxData,
store, clrTxStartBit,clrRxStartBit,PREADY,PSTRB);

uart_tx uart_tx1(txData, txStart, BaudClk, clk, rst,txd, clrTxStartBit, enBaudClk,
rstBaudClkCntr);

BaudClkGen Baud (clk, rst, enBaudClk, rstBaudClkCntr, BaudClk);
uart_rx uart_rx1(rxStart, clk, rst, rxd, clrRxStartBit, store, rxData);
endmodule