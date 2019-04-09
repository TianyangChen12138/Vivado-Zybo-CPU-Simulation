# Vivado-Zybo-CPU-Simulation
Used Verilog and Zybo hardware to simulate CPU’s reading and writing environment

Used Vivado software and Verilog language for coding

We were tasked with implementing the instruction decode and the execution stages of the MIPS architecture. For our design, we assumed that pipelining would be utilized, and as a result implemented registers accordingly. In lab2, in order to realize the design requirements laid out, we first created modules for the basic components of the circuit utilizing the behavioral method of verilog programming. These modules included a mux, ALU, various controls, and registers. Then in lab3, we instantiated them in their respective main modules, labeled main, which connected them in a structural fashion to realize the desired stages of the MIPS architectur. Finally, we connected lab3 code with a series of testbenches to try and showcase how it all works together (results are stored in 'waveform' folder)
