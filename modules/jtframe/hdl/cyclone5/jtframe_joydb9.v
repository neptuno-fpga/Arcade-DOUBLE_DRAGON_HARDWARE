/*
  
   Multicore 2 / Multicore 2+
  
   Copyright (c) 2017-2020 - Victor Trucco

  
   All rights reserved
  
   Redistribution and use in source and synthezised forms, with or without
   modification, are permitted provided that the following conditions are met:
  
   Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
  
   Redistributions in synthesized form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
  
   Neither the name of the author nor the names of other contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.
  
   THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
  
   You are responsible for any legal issues arising from your use of this code.
  
*/module joy_db9 
(
 input  clk,      //Reloj de Entrada sobre 48-50Mhz
 output JOY_CLK,
 output JOY_LOAD,   
 input  JOY_DATA, 
 output reg [15:0] joystick1,
 output reg [15:0] joystick2
);
//Gestion de Joystick
reg [7:0] JCLOCKS;
always @(posedge clk) begin 
   JCLOCKS <= JCLOCKS +8'd1;
end

reg [15:0] joy1  = 16'hFFFF, joy2  = 16'hFFFF;
reg joy_renew = 1'b1;
reg [4:0]joy_count = 5'd0;
   
assign JOY_CLK = JCLOCKS[6];
assign JOY_LOAD = joy_renew;
always @(posedge JOY_CLK) begin 
    if (joy_count == 5'd0) begin
       joy_renew = 1'b0;
    end else begin
       joy_renew = 1'b1;
    end
    if (joy_count == 5'd14) begin
      joy_count = 5'd0;
    end else begin
      joy_count = joy_count + 1'd1;
    end      
end
always @(posedge JOY_CLK) begin
    case (joy_count)
				5'd2  : joy1[5]  <= JOY_DATA; //1p Fuego 2
				5'd3  : joy1[4]  <= JOY_DATA; //1p Fuego 1 
				5'd4  : joy1[0]  <= JOY_DATA; //1p Derecha 
				5'd5  : joy1[1]  <= JOY_DATA; //1p Izquierda
				5'd6  : joy1[2]  <= JOY_DATA; //1p Abajo
				5'd7  : joy1[3]  <= JOY_DATA; //1p Ariba
				5'd8  : joy2[5]  <= JOY_DATA; //2p Fuego 2
				5'd9  : joy2[4]  <= JOY_DATA; //2p Fuego 1
				5'd10 : joy2[0]  <= JOY_DATA; //2p Derecha
				5'd11 : joy2[1]  <= JOY_DATA; //2p Izquierda
				5'd12 : joy2[2]  <= JOY_DATA; //2p Abajo
				5'd13 : joy2[3]  <= JOY_DATA; //2p Arriba
    endcase              
end
always @(posedge clk) begin
`ifndef JOY_GUNSMOKE
    joystick1[15:0] <=  ~joy1;
    joystick2[15:0] <=  ~joy2;

`else //Se convierte 1 disparo mas direccion, a 3 disparos.
	joystick1[15:7] <=  ~joy1[15:7];
	joystick1[3:0]  <=  ~joy1[3:0];
	joystick1[4]    <=  ~joy1[4] &  joy1[0] & ~joy1[1]; //pulsado Fuego e Izquierda
	joystick1[5]    <=  ~joy1[4] &  joy1[0] &  joy1[1]; //Solo pulsado el fuego sin derecha ni izda
	joystick1[6]    <=  ~joy1[4] & ~joy1[0] &  joy1[1]; //pulsado Fuego y Derecha
	

	joystick2[15:7] <=  ~joy2[15:7];
	joystick2[3:0]  <=  ~joy2[3:0];
	joystick2[4]    <=  ~joy2[4] &  joy2[0] & ~joy2[1]; //pulsado Fuego e Izquierda
	joystick2[5]    <=  ~joy2[4] &  joy2[0] &  joy2[1]; //Solo pulsado el fuego sin derecha ni izda
	joystick2[6]    <=  ~joy2[4] & ~joy2[0] &  joy2[1]; //pulsado Fuego y Derecha
`endif	
end

endmodule