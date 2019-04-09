//ALU_Control Module

module ALU_CONTROL (

input[1:0] ALUOP,

input [5:0] funct ,

output reg [2:0] contin

);
always @ (ALUOP or funct)
begin
case (ALUOP) //check value of ALUOP and make output assignments accordingly
2'b00: begin
contin = 3'b010;
end
2'b01: begin
contin = 3'b110;
end
2'b10: begin
case (funct) // assign based on value of funct for this special case of ALUOP
6'b100000 : contin = 3'b010;
6'b100010 : contin = 3'b110;
6'b100100 : contin = 3'b000;
6'b100101 : contin = 3'b001;
6'b101010 : contin = 3'b111;
default : contin = 3'b010;
endcase
end
default: begin
contin = 3'b010;
end
endcase
end
endmodule



//Adder Module

module ADDER(

input [31:0] add_in1, add_in2,

output reg [31:0] add_out
);

always @(add_in1 or add_in2)

begin


add_out <= add_in1 + add_in2; //add the two inputs


end

endmodule



//Mux Module

`timescale 1ns/1ps

module mux2to1 (sel, a0, a1, out);
input sel;
input [31:0] a0, a1;
output reg [31:0] out;

always @ (sel or a0 or a1)
begin
case(sel) // assign output based on the value of sel
0:out = a0;
1:out = a1;
endcase
end

endmodule



//ALU Module

`timescale 1ns/1ps

module alu(ctl, a0, a1, Out, Zero);
input [2:0] ctl;
input [31:0] a0,a1;
output reg [31:0] Out;
output Zero;
assign Zero = (Out==0);
always @(ctl, a0, a1)
begin
case (ctl) //test value of ctl and perform an operation accordingly
0: Out <= a0 & a1;
1: Out <= a0 | a1;
2: Out <= a0 + a1;
6: Out <= a0 - a1;
7: Out <= a0 < a1 ? 1 : 0;
default: Out<=0;
endcase
end
endmodule



//EX_MEM Module

module EX_MEM (
input clock,
input [1:0] ctlwb_out,
input [2:0] ctlm_out,
input aluzero,
input [31:0] addout, aluout, readdat2,
input [4:0] muxout,
output reg MemRead, MemWrite, MEM_Branch,
output reg [1:0] wb_ctlout,
output reg [31:0] add_result, alu_result, rdata2out,
output reg [4:0] five_bit_muxout,
output reg zero
);

initial

begin

MemRead <= 0;

MemWrite <= 0;

MEM_Branch <= 0;

wb_ctlout <= 0;

add_result <= 0;

alu_result <= 0;

rdata2out <= 0;

five_bit_muxout <= 0;

zero <= 0;

end

always @(posedge clock) //pass inputs to next stage each clock cycle

begin

MemRead <= ctlm_out[0];

MemWrite <= ctlm_out[1];

MEM_Branch <= ctlm_out[2];

wb_ctlout <= ctlwb_out;

add_result <=  addout;

alu_result <= aluout;

rdata2out <= rdata2out;

five_bit_muxout <= five_bit_muxout;

zero <= aluzero;
end
endmodule



//Main Module

`timescale 1ns/1ps

module I_EXECUTE(clock, WB, M, EX_MEM_latch, EX_adder, EX_ALU, IR, EX_mux0, EX_mux1, RegDst, ALUOp, ALUSrc, MemRead, MemWrite, MEM_Branch, IF_mux, alu_result, rdata2out, zero, five_bit_muxout, wb_ctlout);

//Keep in mind an output from each main module is supposed to go "TO" more than one output
input [31:0] EX_adder;
input [31:0] EX_ALU;
input [31:0] IR;
input [16:20] EX_mux0;
input [11:15] EX_mux1;
input [31:0] EX_MEM_latch;
input [1:0] WB;
input [2:0] M;
input clock, RegDst, ALUSrc;
input [1:0] ALUOp;

output MemRead, MemWrite, MEM_Branch;
output [31:0] IF_mux; //add_result

output [31:0] alu_result, rdata2out;
output zero;
output [4:0] five_bit_muxout;
output [1:0] wb_ctlout;

wire zero;
wire [2:0] select;
wire [4:0] y1, y2;
wire [31:0] result, add_out;

ALU_CONTROL alucon
(
	.ALUOP   	 (ALUOp   			 ),
	.funct		 (IR[5:0]   		 ),
	.contin   	 (select   			 )
);

ADDER adder1 //created from last lab's incrementer
(
    .add_in1    (EX_adder    ),
    .add_in2    (IR   		 ),
    .add_out    (add_out    )
);

mux2to1 ALU_MUX
(
	.sel	(ALUSrc  		 ),
	.a0 	(EX_MEM_latch   ),
	.a1 	(IR   			 ),
	.out	(y1  			 )
);

alu ALU
(
	.ctl    (select   	 ),
	.a0   	 (EX_ALU  	 ),
	.a1   	 (y1      	 ),
	.Out    (result   	 ),
	.Zero    (zero   	 )
    
);

mux2to1 BOTTOM_MUX
(
	.sel	(RegDst   				 ),
	.a0 	(EX_mux0   			 ),
	.a1 	(EX_mux1   			 ),
	.out	(y2  					 )
);

EX_MEM EX_MEM1
(
	.clock   			 (clock   		 ),
    .ctlwb_out 		 (WB   			 ),
    .ctlm_out  		 (M   			 ),
    .addout  		 (add_out   	 ),
    .aluzero  			 (zero  		 ),
    .aluout  			 (result  		 ),
    .readdat2  		 (EX_MEM_latch   ),
    .muxout 			 (y2   		 	),
    
    .wb_ctlout  		 (wb_ctlout   		 ),
    .MemRead  			 (MemRead   		 ),
    .MemWrite 		      (MemWrite   		 ),
    .MEM_Branch   	 	(MEM_Branch   		 ),
    .add_result  		 (IF_mux    		 ),
    .zero  			 (zero   			 ),
    .alu_result  		 (alu_result   		 ),
	.rdata2out   		 (rdata2out   		 ),
	.five_bit_muxout    (five_bit_muxout    )
);

endmodule