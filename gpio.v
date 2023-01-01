`define control_register_address 2'b01
`define data_register_address 2'b00
`timescale 1ns/1ps
`define DATAWIDTH 8
`define ADDRWIDTH 8
`define IDLE     2'b00
`define W_ENABLE  2'b11
`define R_ENABLE  2'b01
module gpio_controller
(
  input                         PCLK,
  input                         PRESETn,
  input        [31:0] PADDR,
  input                         PWRITE,
  input                         PSEL,
  input        [31:0] PWDATA,
  input        [3:0]PSTRB,
  input                         PENABLE,
  output reg   [31:0] PRDATA,
  output reg                    GPIO_PREADY,
  output reg [1:0]              State ,
  output reg [8:0]  GPIO_CONTROL ,
  output reg [8:0]  GPIO_DATA  ,
  output reg PSLVERR  


  );
reg [8:0] data ;

always @(posedge PRESETn or posedge PCLK) begin
  if (PRESETn == 1'b0) begin
    State <= `IDLE;
    GPIO_CONTROL<= 8'b00;
    GPIO_DATA<= 8'b00;
    PSLVERR  <=1'b0;
    GPIO_PREADY <= 1'b1;
    end

  else begin
    case (State)
      `IDLE : begin
        GPIO_PREADY <=1'b1; 
        PSLVERR  <=0;
        if (PSEL) begin
          if (PWRITE) begin
            State <= `W_ENABLE;
          end
          else begin
            State <= `R_ENABLE;
          end
        end
      end

      `W_ENABLE : begin
        if (PSEL && PWRITE&& GPIO_PREADY && PENABLE ) begin
        case (PSTRB) 
            4'b0001 :
            data= PWDATA[7:0]; 
            4'b0010 :
            data= PWDATA[15:8];  
            4'b0100:
            data= PWDATA[23:16];
            4'b1000 : 
            data= PWDATA[31:24];    
          default:
          PSLVERR  =1'b1;   
          endcase 
          if(PSLVERR  ==1'b0)begin
          if(PADDR==`control_register_address)begin
          GPIO_CONTROL=data;
          end
          else if (PADDR==`data_register_address)begin
          if(GPIO_CONTROL[0]) //if this bit is output
          GPIO_DATA[0]=data[0];
          if(GPIO_CONTROL[1])
          GPIO_DATA[1]=data[1];
          if(GPIO_CONTROL[2])
          GPIO_DATA[2]=data[2];
          if(GPIO_CONTROL[3])
          GPIO_DATA[3]=data[3];
          if(GPIO_CONTROL[4])
          GPIO_DATA[4]=data[4];
          if(GPIO_CONTROL[5])
          GPIO_DATA[5]=data[5];
          if(GPIO_CONTROL[6])
          GPIO_DATA[6]=data[6];
          if(GPIO_CONTROL[7])
          GPIO_DATA[7]=data[7];
          end   
          GPIO_PREADY <=1'b0; 
        end
          State <= `IDLE;
       end
    end

 `R_ENABLE : begin 
        if(PSTRB==0) begin
        PSLVERR  <= 1'b0;
          if (PSEL && !PWRITE && GPIO_PREADY && PENABLE) begin
            GPIO_PREADY <= 1'b0;
            if(PADDR==`control_register_address)
            PRDATA <= GPIO_CONTROL;
            else
              PRDATA <= GPIO_DATA;
          end
          end
       else 
        PSLVERR  <= 1'b1;
      State <= `IDLE;
      end

      default: begin
        State <= `IDLE;
      end
    endcase
  end
end 
endmodule