//Control Module

module CONTROL (
input[5:0] opcode,
output reg [1:0] WB,
output reg [2:0] M,
output reg [3:0] EX
);

always @ (opcode)
Begin 
case (opcode) // check value of opcode and assign outputs accordingly
6'b000000: begin
EX = 4'b1100;
M = 3'b000;
WB = 2'b10;
end
6'b000100: begin
EX = 4'b1010;
M = 3'b100;
WB = 2'b00;
end
6'b100011: begin
EX = 4'b0001;
M = 3'b010;
WB = 2'b11;
end
6'b101011:begin
EX = 4'b0001;
M = 3'b001;
WB = 2'b00;
end
default: begin
EX = 4'b1100;
M = 3'b000;
WB = 2'b10;
end
endcase
end
endmodule



//Register Module

module REG(

input [4:0] read1, read2, write1,
input [31:0] writedata,
input wexert,
output reg [31:0] data1, data2
);
reg [31:0] memory [0:31];

initial //initialize register memory
begin

	memory [0] <= 32'h002300AA;

	memory[1] <= 32'h10654321;

	memory [2] <= 32'h00100022;

	memory[3] <= 32'h8C123456;

	memory [4] <= 32'h8F123456;

	memory[5] <= 32'hAD654321;

	memory [6] <= 32'h13012345;

	memory[7] <= 32'hAC654321;

memory [8] <= 32'h12012345;

end

always @(read1 or read2)

begin
data1 = memory [read1]; //assign data1 output based on input address
data2 = memory [read2]; //assign data2 output based on input address
end
always @ (wexert == 1) //check to see write is enabled
begin

memory [write1] <= writedata;
end
endmodule



//Sign Extend Module

module S_EXTEND(

input [15:0] in,

output reg [31:0] out

);
reg [15:0] temp;

always @ (*)
begin
if (in[15] == 1) //test sign of input
begin
temp = 16'hffff; //sign extend with ones if negative
end
else
begin
temp = 16'h0000; //sign extend with 0’s otherwise
end
out[31:16] <= temp[15:0]; //concatenate extension with input
out [15:0] <= in[15:0];
end
endmodule



//ID_EX Module

module ID_EX (
input clock,
input [1:0] ctlwb_out,
input [2:0] ctlm_out,
input [3:0] ctlex_out,
input [31:0] npc, readdat1, readdat2, signext_out,
input [4:0] instr_2016, instr_1511,

output reg RegDst, ALUSrc,
output reg [1:0] wb_ctlout, ALUOp,
output reg [2:0] m_ctlout,
output reg [31:0] npcout, readdat1out, readdat2out, s_extendout,
output reg [4:0] instrout_2016, instrout_1511
);
initial
begin
wb_ctlout <= 0;
m_ctlout <= 0;
RegDst <= 0;
ALUOp <= 0;
ALUSrc <= 0;
npcout <= 0;
readdat1out <= 0;
readdat2out <= 0;
s_extendout <= 0;
instrout_2016 <= 0;
instrout_1511 <= 0;
end
always @(posedge clock) //pass inputs to next stage each clock cycle
begin
wb_ctlout <= ctlwb_out;
m_ctlout <= ctlm_out;
RegDst <= ctlex_out[0];
ALUOp <= ctlex_out[2:1];
ALUSrc <= ctlex_out[3];
npcout <= npc;
readdat1out <= readdat1;
readdat2out <= readdat2;
s_extendout <= signext_out;
instrout_2016 <= instr_2016;
instrout_1511 <= instr_1511;
end
endmodule



//Main Module

`timescale 1ns/1ps

module I_DECODE(clock, IF_ID_latch, EX_through, MEM_WB_latch, WB_mux, Reg_Write, WB, M, RegDst, ALUOp, ALUSrc, EX_adder, EX_ALU, EX_MEM_latch, IR, EX_mux0, EX_mux1);

input [31:0] IF_ID_latch;
input [31:0] EX_through;
input clock, Reg_Write;
input [4:0] MEM_WB_latch;
input [31:0] WB_mux;

output RegDst, ALUOp, ALUSrc;
output [1:0] WB;
output [2:0] M;
output [31:0] EX_adder;
output [31:0] EX_ALU;
output [31:0] EX_MEM_latch;
output [31:0] IR;
output [16:20] EX_mux0;
output [11:15] EX_mux1;

wire [1:0] wire_WB;
wire [2:0] wire_M;
wire [3:0] wire_EX;
wire [31:0] RegOutA, RegOutB, SExtendOut;

CONTROL con
(
	.opcode   	 (IF_ID_latch [31:26]    ),
	.WB			 (WB   		 ),
	.M   		 (M   		 ),
	.EX   		 (EX   		 )
);

REG register
(
	.read1   	 (IF_ID_latch [25:21]    ),
	.read2   	 (IF_ID_latch [20:16]    ),
    .write1   	 (MEM_WB_latch   		 ),
    .writedata    (WB_mux   				 ),
    .wexert   	 (Reg_Write   			 ),
    .data1   	 (RegOutA   			 ),
    .data2   	 (RegOutB   			 )
    
);

S_EXTEND signextend
(
    .in   	 (IF_ID_latch [15:0]    ),
    .out   	 (SExtendOut   		 )
);


ID_EX IdExReg
(
	.clock   		 (clock   				 ),
    .ctlwb_out 		 (wire_WB   			 ),
    .ctlm_out  		 (wire_M   				 ),
    .ctlex_out  		 (wire_EX   					 ),
    .npc  			 (EX_through  		 ),
    .readdat1  		 (RegOutA   			 ),
    .readdat2  		 (RegOutB   			 ),
    .signext_out  		 (SExtendOut  			 ),
    .instr_2016  		 (IF_ID_latch [20:16]	),
    .instr_1511  		 (IF_ID_latch [15:11]	),
    
    .wb_ctlout  		 (WB   					 ),
    .m_ctlout  		 (M   					 ),
    .RegDst   		 (RegDst    ),
    .ALUSrc   		 (ALUSrc    ),    
    .ALUOp   		 (ALUOp    ),
    .npcout  			 (EX_adder    			 ),
    .readdat1out  		 (EX_ALU    			 ),
    .readdat2out  		 (EX_MEM_latch   		 ),
	.s_extendout   	 (IR    				 ),
	.instrout_2016   	 (EX_mux0    			 ),
	.instrout_1511   	 (EX_mux1    			 )
);

endmodule