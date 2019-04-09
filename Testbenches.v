//5-Bit Mux_Testbench

`timescale 1ns/1ps
// Filename: test-5bitmux.v
// Description: Testing the 5bitmux module of the EX stage of the pipeline.
module test_5bitmux ( );
// Wire Ports
wire [4:0] Y;
// Register Declarations
reg [4:0] A, B;
reg sel;
reg clk;

wire [31:0] IF_ID_IR, IncrOut;

wire [1:0] WB;
wire [2:0] M;
wire [1:0] alu_op;
wire ALUsrc;
wire [31:0] EX_adder, EX_ALU, EX_MEM_latch, IR;

wire [1:0] wb_ctlout;
wire MemRead, MemWrite, MEM_Branch;
wire [31:0] add_result, alu_result, rdata2out; //add_result?
wire zero;
wire [4:0] five_bit_muxout;

//wire IF_mux?
//wire seltemp;
//wire [4:0] Atemp, Btemp;

IF main
(
    .PC_choose    (1'b0    ),
    .EX_MEM_NPC    (32'd0    ),

    .IF_ID_IR    (IF_ID_IR    ),
    .IF_ID_NPC    (IncrOut    ),
    .clock   	 (clk    )
);

I_DECODE main2
(
    .clock   	 (clk    ),
    .IF_ID_latch    (IF_ID_IR    ),
    .EX_through    (IncrOut    ),
    .MEM_WB_latch    (0    ),
    .WB_mux   	 (0    ),
	 .Reg_Write    (0    ),
 
    .WB   	 (WB    ),
    .M   	 (M    ),
    .RegDst   	 (seltemp    ),
    .ALUOp   	 (alu_op    ),
    .ALUSrc   	 (ALUsrc    ),
    .EX_adder    (EX_adder    ),
    .EX_ALU   	 (EX_ALU    ),
    .EX_MEM_latch    (EX_MEM_latch    ),
    .IR   	 (IR    ),
    .EX_mux0    (Atemp    ),
    .EX_mux1    (Btemp    )
);

//instantiate the mux
mux2to1 mux1
(
    .out    (Y    ),
 
    .a0    (A    ),
    .a1    (B    ),
    .sel    (sel    )
);

I_EXECUTE main3
(
    .clock   		 (clk    ),
    .WB   		 (WB    ),
    .M   		 (M    ),
    .EX_MEM_latch   	 (EX_MEM_latch),
    .EX_adder   	 (EX_adder    ),
    .EX_ALU   		 (EX_ALU    ),
    .IR   		 (IR    ),
    .EX_mux0   	 (A /*EX_mux0*/    ),
    .EX_mux1   	 (B /*EX_mux1*/    ),
    .RegDst   		 (sel /*RegDst*/    ),
    .ALUOp   		 (ALUOp    ),
    .ALUSrc   		 (ALUSrc    ),

    .MemRead   	 (MemRead    ),
    .MemWrite   	 (MemWrite    ),
    .MEM_Branch   	 (MEM_Branch    ),
    .IF_mux   		 (IF_mux    ),
    .alu_result   	 (alu_result    ),
    .rdata2out   	 (rdata2out    ),
    .zero   		 (zero    ),
    .five_bit_muxout    (five_bit_muxout    ),
    .wb_ctlout   	 (wb_ctlout    )
);

always begin
#5 clk = ~clk;
end

initial begin
clk = 0;

A = 5'b01010;
B = 5'b10101;
sel = 1'b1;
#10
A = 5'b00000;
#10
sel = 1'b1;
#10
B = 5'b11111;
#5
A = 5'b00101;
#5
sel = 1'b0;
B = 5'b11101;
#5
sel = 1'bx;
end
endmodule
// test



//ALU Control Testbench

`timescale 1ns/1ps
// Filename : test-alucontrol.v
// Description: Testing the ALU control module of the EX stage of the pipeline.
module test_alucontrol( ) ;
// Wire Ports
wire [2:0] select;
// Register Declarations
reg [1:0] alu_op;
reg [5:0] funct;
reg clk;

wire [31:0] IF_ID_IR, IncrOut;

wire [1:0] WB;
wire [2:0] M;
wire ALUsrc;
wire [31:0] EX_adder, EX_ALU, EX_MEM_latch, IR;

wire [1:0] wb_ctlout;
wire MemRead, MemWrite, MEM_Branch;
wire [31:0] alu_result, rdata2out; //add_result
wire zero;
wire [4:0] five_bit_muxout;
wire RegDst;
wire [4:0] EX_mux0, EX_mux1;

wire ALUsrctemp; //Unused

wire IF_mux;

wire [1:0] alu_optemp;

IF main
(
    .clock   	 (clk    ),
    .PC_choose    (1'b0    ),
    .EX_MEM_NPC    (32'd0    ),

    .IF_ID_IR    (IF_ID_IR    ),
    .IF_ID_NPC    (IncrOut    )
);

I_DECODE main2
(
    .clock   	 (clk    ),
    .IF_ID_latch    (IF_ID_IR    ),
    .EX_through    (IncrOut    ),
    .MEM_WB_latch    (0    ),
    .WB_mux   	 (0    ),
	 .Reg_Write    (0    ),
 
    .WB   	 (WB    ),
    .M   	 (M    ),
    .RegDst   	 (RegDst    ),
    .ALUOp   	 (alu_optemp    ),
    .ALUSrc   	 (ALUsrc    ),
    .EX_adder    (EX_adder    ),
    .EX_ALU   	 (EX_ALU    ),
    .EX_MEM_latch    (EX_MEM_latch    ),
    .IR   	 (IR    ),
    .EX_mux0    (EX_mux0    ),
    .EX_mux1    (EX_mux1    )
);

ALU_CONTROL alucontrol1
(
    .ALUOP    (alu_op    ),
    .funct    (funct    ),

    .contin    (select    ) // Wire in I_EXECUTE, how do I pass this on to the next module?
);


I_EXECUTE main3
(
    .clock   		 (clk    ),
    .WB   		 (WB    ),
    .M   		 (M    ),
    .EX_MEM_latch   	 (EX_MEM_latch),
    .EX_adder   	 (EX_adder    ),
    .EX_ALU   		 (EX_ALU    ),
    .IR   		 (IR    ),
    .EX_mux0   	 (EX_mux0    ),
    .EX_mux1   	 (EX_mux1    ),
    .RegDst   		 (RegDst    ),
    .ALUOp   		 (alu_op    ),
	 .ALUSrc   		 (ALUSrc    ),
 
    .MemRead   	 (MemRead    ),
    .MemWrite   	 (MemWrite    ),
    .MEM_Branch   	 (MEM_Branch    ),
    .IF_mux   		 (IF_mux    ),
    .alu_result   	 (alu_result    ),
    .rdata2out   	 (rdata2out    ),
    .zero   		 (zero    ),
    .five_bit_muxout    (five_bit_muxout    ),
    .wb_ctlout   	 (wb_ctlout    )
);

always begin
#5 clk = ~clk;
end

initial begin
clk = 0;
alu_op = 2'b00;
funct = 6'b100000;
#10
alu_op = 2'b01;
funct= 6'b100000;
#10
alu_op = 2'b10;
funct =6'b100000;
#10
funct = 6'b100010;
#10
funct = 6'b100100;
#10
funct = 6'b100101;
#10
funct = 6'b101010;
//#1
//$finish;
end
endmodule
// test



//ALU Testbench

`timescale 1ns/1ps
// Filename : test-alu.v
// Description: Testing module for the ALU
module test_alu ( ) ;

//// Register Declarations
reg [31:0] A,B ;
reg [2:0] control;
// Wire Ports
wire [31:0] result ;
wire zero1, zero2;
reg clk;


wire [31:0] IF_ID_IR, IncrOut;

wire [1:0] WB;
wire [2:0] M;
wire RegDst;
wire [1:0] alu_op;
wire ALUsrc;
wire [31:0] EX_adder, EX_ALU, EX_MEM_latch, IR;

wire [1:0] wb_ctlout;
wire MemRead, MemWrite, MEM_Branch;
wire [31:0] rdata2out, alu_result; //add_result
wire [4:0] five_bit_muxout;
wire [4:0] EX_mux0, EX_mux1;

wire IF_mux;


IF main
(
    .PC_choose    (1'b0    ),
    .EX_MEM_NPC    (32'd0    ),
    .IF_ID_IR    (IF_ID_IR    ),
    .IF_ID_NPC    (IncrOut    ),
    .clock   	 (clk    )
);

I_DECODE main2
(
    .clock   	 (clk    ),
    .IF_ID_latch    (IF_ID_IR    ),
    .EX_through    (IncrOut    ),
//The three following  inputs are set to zero because their values would come from future 
//modules we haven’t created yet. They have no data at this time, and do not directly affect the three main //components we are currently testing with our testbenches.
    .MEM_WB_latch    (0    ), 
    .WB_mux   	 (0    ),
	 .Reg_Write    (0    ),
 
    .WB   	     	(WB    ),
    .M   	     	(M    ),
    .RegDst   	 	(RegDst    ),
    .ALUOp   	 	(alu_op    ),
    .ALUSrc   	 	(ALUsrc    ),
    .EX_adder    	(EX_adder    ),
    .EX_ALU   	 	(EX_ALU    ),
    .EX_MEM_latch    (EX_MEM_latch    ),
    .IR   	     	(IR    ),
    .EX_mux0    	(EX_mux0    ),
    .EX_mux1    	(EX_mux1    )
);

alu ALU1
(
    .Out   	 (result   	 ),
    .Zero   	 (zero1   	 ),

    .a0   	 	(A   	 ),
    .a1   	 	(B   	 ),
    .ctl   	 (control    )
);

I_EXECUTE main3
(
    .clock   		 (clk    ),
    .WB   		  	(WB    ),
    .M   		   	(M    ),
    .EX_MEM_latch   	 (EX_MEM_latch),
    .EX_adder   	 (EX_adder    ),
    .EX_ALU   		 (EX_ALU    ),
    .IR   		 	(IR    ),
    .EX_mux0   	 (EX_mux0    ),
    .EX_mux1   	 (EX_mux1    ),
    .RegDst   		 (RegDst    ),
    .ALUOp   		 (alu_op    ),
 
    .ALUSrc   		 (ALUSrc    ),
    .MemRead   	 (MemRead    ),
    .MemWrite   	 (MemWrite    ),
    .MEM_Branch   	 (MEM_Branch    ),
    .IF_mux   		 (IF_mux    ),
    .alu_result   	 (alu_result    ),
    .rdata2out   	 (rdata2out    ),
    .zero   		 (zero2    ),
    .five_bit_muxout    (five_bit_muxout    ),
    .wb_ctlout   	 (wb_ctlout    )
);
always begin
#5 clk = ~clk;
end

initial begin
clk = 0;

A <= 4'b1010;
B <= 4'b0111;
control <= 3'b011;

#10
control <= 3'b100;
#10
control <= 3'b010;
#10
control <= 3'b111;
#10
control <= 3'b011;
#10
control <= 3'b110;
#10
control <= 3'b001;
#10
control <= 3'b000;
//#1
//$finish ;
end
endmodule
//test