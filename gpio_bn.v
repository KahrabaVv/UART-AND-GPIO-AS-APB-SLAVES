`timescale 1ns/1ps
`define control_register_address 2'b01
`define data_register_address 2'b00
`define DATAWIDTH 32
`define ADDRWIDTH 32
module APB_GPIO_tb ();

  reg                         PCLK;
  reg                         PRESETn;
  reg        [`ADDRWIDTH-1:0] PADDR;
  reg                         PWRITE;
  reg                         PSEL;
  reg     	 [`DATAWIDTH-1:0] PWDATA;
  reg                    [3:0]PSTRB;
  reg                        PENABLE;
  wire 	  	 [`DATAWIDTH-1:0] PRDATA;
  wire	     GPIO_PREADY;
  wire [1:0]              State ;
  wire 	 	 [8:0] GPIO_CONTROL;
  wire 	 	 [8:0] GPIO_DATA;
  wire PSLVERR  ;
gpio_controller a (PCLK, PRESETn,PADDR,PWRITE,PSEL,PWDATA,PSTRB,PENABLE,PRDATA,GPIO_PREADY,State,GPIO_CONTROL,GPIO_DATA,PSLVERR  );



initial
 begin
    PCLK = 0;
    PRESETn=1'b1;
 #15 PRESETn=~PRESETn;
 #10 PRESETn=~PRESETn;
    PSEL = 0;
    #5
    test_gpio_module;
    #10000; 
    $finish;
  end
  always 
  begin
   #5  PCLK = ~PCLK;
  end

task 
test_gpio_module;
 begin
  #5
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`control_register_address,1);
   #20
   PSTRB=4'b0000;
   PENABLE=1'b0;
   Read(`control_register_address);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,1);
   #10
   PSTRB=4'b0000;
   PENABLE=1'b0;
   Read(`data_register_address);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,2);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,4);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,8);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,16);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,32);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,64);
   #10
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,128);
   PSTRB=4'b0001;
   PENABLE=1'b0;
   Write(`data_register_address,256);
   #10
   PSTRB=4'b0010;
   PENABLE=1'b0;
   Write(`control_register_address,257);
   #10
   PSTRB=4'b0100;
   PENABLE=1'b0;
   Write(`control_register_address,8388608);
   #10
   PSTRB=4'b1000;
   PENABLE=1'b0;
   Write(`control_register_address,16777216);
   #10
   PSTRB=4'b0100;
   PENABLE=1'b0;
   Read(`data_register_address);	
   #10
   PENABLE=1'b0;
   PSTRB=4'b0101;
   Write(`data_register_address ,1);	
end
endtask



 
 task 
  Write(input address , input integer num);
 begin
 	 #5
   @(posedge PCLK) begin
	 	PSEL = 1;
	 	PWRITE = 1;
		PADDR =address ;
    PWDATA=num ;
    $monitor("PADDR %h, PRDATA %h ,GPIO_DATA %h ,GPIO_CONTROL %h ,PWDATA %h , num %h,PSLVERR   %h, PENABLE %h ",PADDR,PRDATA,GPIO_DATA,GPIO_CONTROL,PWDATA ,num,PSLVERR ,PENABLE );
    #10
    PENABLE=1'b1;
    #20
    PSEL=0;
    PENABLE=1'b0;
	 end 
end
endtask

		 
task 
Read(input address);
begin 
	#10
	@(posedge PCLK) begin
	 	PSEL = 1;
	 	PWRITE = 0;
		PADDR = address;
    $monitor("PADDR %h, PRDATA %h ,GPIO_DATA %h ,GPIO_CONTROL %h ,PWDATA %h ,PSLVERR   %h, PENABLE %h ",PADDR,PRDATA,GPIO_DATA,GPIO_CONTROL,PWDATA ,PSLVERR ,PENABLE );
    #10
    PENABLE=1'b1;
    #20
    PSEL=0;
    PENABLE=1'b0;
   end
end
endtask
 		
 endmodule
