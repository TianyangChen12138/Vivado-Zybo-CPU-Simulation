//Mux
`timescale 1ns/1ps

module mux2to1 (sel, a0, a1, out);
// establish inputs and outputs
input sel;
input [31:0] a0, a1;
output reg [31:0] out;

always @ (sel or a0 or a1)
begin
case(sel)
// use a case statement to determine the output based on the select value
0:out = a0;
1:out = a1;
endcase
end

endmodule



//Program Counter

`timescale 1ns/1ps

module program_counter (NPCin, NPCout, clk);
//declare inputs and outputs
input clk;
input [31:0] NPCin;
output reg [31:0] NPCout;
initial
Begin
// set the initial program count to 0
NPCout <= 0;
end

always @ (posedge clk)
// evaluate the new program count once per clock cycle
begin
//pass the new program count to the rest of the circuit
NPCout <= NPCin;
end
endmodule



//Adder
`timescale 1ns/1ps

//This module was initially a full-blown ALU created behaviorally
//We ran into some minor issues when using it with the testbenches, however
//For this reason, we felt that a simpler and more reliable pure-adder that can be used to increment was a better //decision for this project
//We still have the ALU module, however, knowing that it appears elsewhere in the MIPS pipeline
//We will likely perfect and implement the full module in future labs and projects

module INCR(IncrOut, a);
//establish inputs and outputs
input [31:0] a;
output reg [31:0] IncrOut;
always @(a)
//evaluate whenever the input changes
Begin
// increment by 4 bytes
IncrOut = a + 4;
end
endmodule



//Instruction Memory

`timescale 1ns/1ps

module Instruction_memory (address, data);
//establish inputs and outputs
input [31:0] address;
output reg [31:0] data;
reg [31:0] memory [0:127];
initial
begin
// initialize memory
	memory [0] <= 32'hA00000AA;
	memory[4] <= 32'h10000011;
	memory [8] <= 32'h20000022;
	memory[12] <= 32'h30000033;
	memory [16] <= 32'h40000044;
	memory[20] <= 32'h50000055;
	memory [24] <= 32'h60000066;
	memory[28] <= 32'h70000077;
	memory [32] <= 32'h80000088;
	memory[36] <= 32'h90000099;
end
always @(address)
//evaluate whenever a new address is received
begin
//pass the result stored in the desired memory address
data <= memory [address];
end
endmodule



//Instruction Fetch/Instruction Decode Register

module If_Id_REG (
input wire [31:0] NPCin, instin,
output reg [31:0] NPCout, instout
);
initial
begin
//initialize values
instout <= 0;
NPCout <= 0;
end
always @(*)
begin
//pass new values to the next stage of the circuit
NPCout <= NPCin;
instout <= instin;
end
endmodule



//Main Module

`timescale 1ns/1ps

module IF(PC_choose, EX_MEM_NPC, IF_ID_IR, IF_ID_NPC, clock);
// declare inputs and outputs
input PC_choose;
input [31:0] EX_MEM_NPC;
input clock;
output [31:0] IF_ID_NPC, IF_ID_IR;
wire [31:0] mux_output, PC_output, incrementer_output, IM_output;
// implement the mux to choose which value is passed to the PC. In this case it’s always the incremented program count

mux2to1 mux2
(
	.sel	(PC_choose	),
	.a0 	(incrementer_output   ),
	.a1 	(EX_MEM_NPC	),
	.out	(mux_output	)
);

//implement the PC to pass the program count to the instruction memory and incrementer each clock cycle.
program_counter ProgCount
(
	.NPCin    	(mux_output	),
	.NPCout   	(PC_output	),
   .clk      	(clock)
   
);

// implement the incrementer to increase the program count by 4 bytes
INCR incrementer2
(
   .IncrOut    (incrementer_output    ),
   .a        	(PC_output    )
);


//implement the instruction memory to determine the procedure that should take place given the program count
Instruction_memory IM
(
	.address 	(PC_output	),
	.data    	(IM_output	)
);

//implement a register to hold values and allow for pipelining
If_Id_REG IFIDreg
(
	.NPCin  	(incrementer_output ),
	.instin 	(IM_output ),
	.NPCout 	(IF_ID_NPC ),
	.instout	(IF_ID_IR )
);

//Everything in this module is called structurally

endmodule