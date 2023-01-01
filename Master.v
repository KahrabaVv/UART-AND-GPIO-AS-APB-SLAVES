`timescale 1ns / 1ps
module apbmaster(
input 		PCLK,
input 		PRESETn,
input 		[1:0]ADD,//00-x,01-read,10-x,11-write
output reg	PSEL,
output reg	PENABLE,
output 		[31:0] PADDR,
output 		PWRITE,
output 		[31:0]PWDATA,
input  		[31:0]PRDATA,
input 		PREADY
    );


reg [31:0]cur_pwrite,nex_pwrite,cur_prdata,nex_prdata;
reg [1:0] cur_s,nex_s;
parameter idle = 2'b00,setup = 2'b01,access = 2'b10;
 
always @(posedge PCLK)
begin
	if(~PRESETn)
	begin
		cur_s <= idle;
		cur_pwrite <= 32'b0;
		end
	else
	begin
		cur_s <= nex_s;
		cur_pwrite <= nex_pwrite;
		cur_prdata <= nex_prdata;
	end
end 

always @(cur_s or ADD)
begin
	case(cur_s)
	idle:begin
			if(ADD[0])
			begin
			nex_s = setup;
			nex_pwrite = ADD[1];
			end
			else
			nex_s = idle;
			end
	setup:begin
				PSEL = 1;
				PENABLE = 0;
				nex_s = access;
			end
	access:begin
				PSEL = 1;
				PENABLE = 1;
				if(PREADY)
				begin
				if(~cur_pwrite)
				begin
				nex_prdata = PRDATA;
				nex_s = idle;
				end
				end
				else
				nex_s = access;
			end
	default:begin
	PSEL = 0;
	PENABLE = 0;
	nex_s = idle;
	nex_prdata = cur_prdata;
	nex_pwrite = cur_pwrite;
	end
	endcase
end



endmodule
