`timescale 1us/100ns
module tb_apbUART();
reg[31:0] padd,pdata;
reg psel,pen,pwr,rst,clk;
reg rxd;
reg times;
reg PSTRB;
wire txd;

wire[31:0] prdata;
localparam  baud  = 102, rx_clk =6.4 ;
apbUART apbUART1(padd, pdata, psel, pen, pwr, rst, clk, prdata, txd, rxd,PSTRB);
initial
begin
clk=1'b1;
times=1'b1;
pdata=0;
pwr=0;
psel=0;
pen=0;
rxd=1;
PSTRB=1'b1;
rst=1'b1;
#60 rst=1'b0;
pdata=8'h5f; 
#20 write_gen;
#90 sendbyte(8'hf5);   
#1000
 $stop;
end
 always
    begin
 #(rx_clk/2) clk=~clk;

    end 
 always
  #(102/2) times=~times;

task
write_gen;
@(posedge clk)
begin
padd=0;
psel=1;
pwr=1;
pen=1;
end
endtask

 
task
sendbyte;

input [7:0] i_Data;
 integer i;
 @(posedge times)
 begin
  pwr=0;
  pen=1;
  psel=1;
  padd=1'b1;
      #102;
      rxd <= 1'b0;
      #102;
      
      rxd <= 1'b1;
      
          for (i=0; i<8; i=i+1)
          begin
            #102;
          rxd <= i_Data[i];
          
          end
  #102;
  rxd <= ^i_Data;
  #102;
  rxd <= 1'b0;
  #102;
  rxd <= 1'b1;
 end         
endtask

endmodule