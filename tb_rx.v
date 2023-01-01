`timescale 1us/100ns
module tb_rx (  
);

reg rxd;
reg rxStart;
reg rst;
reg clk;
reg b;
wire [12:0] rxData;
wire clrRxStartBit;
wire store;
localparam  baud  = 102, rx_clk =6.4 ;

 uart_rx x(rxStart, clk, rst, rxd, clrRxStartBit, store, rxData);



initial
begin
   clk=1'b1;
   b=1'b1;
   rxStart=0;
   rxd=1;
   rst=1'b1;
   #60 rst=1'b0;
  #10 rxStart=1;
   #90 sendbyte(8'h10);
    rxStart=0;
   #100 $stop;
end 
  always
    begin
 #(rx_clk/2) clk=~clk;

    end 
    always
    
     #(baud/2) b=~b;
task
sendbyte;
input [7:0] i_Data;
 integer i;
 @(posedge b)
 begin
      #baud;
      rxd <= 1'b0;
      #baud;
      
      rxd <= 1'b1;
      
          for (i=0; i<8; i=i+1)
          begin
            #baud;
          rxd <= i_Data[i];
          
          end
           #baud;
          rxd <= ^i_Data;
         #baud;
          rxd <= 1'b0;
          #baud;
          rxd <= 1'b1;
          
          

 end         
endtask

endmodule //tb_rx