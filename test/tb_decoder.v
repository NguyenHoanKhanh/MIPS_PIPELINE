`timescale 1ns/1ps
`include "./source/decoder.v"

module tb_decoder;
    reg  d_i_ce;
    reg  [`IWIDTH - 1 : 0] d_i_instr;
    reg  [`DWIDTH - 1 : 0] d_i_data_rd;
    wire d_o_jal;
    wire [`JUMP_WIDTH - 1 : 0] d_o_jal_addr;
    wire [`OPCODE_WIDTH - 1 : 0] d_o_opcode;
    wire [`FUNCT_WIDTH  - 1 : 0] d_o_funct;
    wire [`AWIDTH - 1 : 0] d_o_addr_rs, d_o_addr_rt;
    wire [`AWIDTH - 1 : 0] d_o_addr_rd;
    wire [`DWIDTH - 1 : 0] d_o_data_rs, d_o_data_rt;
    wire [`IMM_WIDTH - 1 : 0] d_o_imm;
    wire d_o_reg_wr;
    wire d_o_alu_src;
    wire d_o_memwrite;
    wire d_o_memtoreg;
    wire d_o_ce;  

    // Instantiate decoder
    decoder dut (
        .d_i_ce(d_i_ce), 
        .d_i_instr(d_i_instr), 
        .d_o_opcode(d_o_opcode), 
        .d_o_funct(d_o_funct), 
        .d_o_addr_rs(d_o_addr_rs), 
        .d_o_addr_rt(d_o_addr_rt),
        .d_o_addr_rd(d_o_addr_rd), 
        .d_o_imm(d_o_imm), 
        .d_o_ce(d_o_ce),
        .d_o_jal(d_o_jal),
        .d_o_alu_src(d_o_alu_src),
        .d_o_reg_wr(d_o_reg_wr),
        .d_o_memwrite(d_o_memwrite),
        .d_o_memtoreg(d_o_memtoreg),
        .d_o_jal_addr(d_o_jal_addr)
    );

    initial begin
        $dumpfile("./waveform/decoder.vcd");
        $dumpvars(0, tb_decoder);
    end

    // Main test sequence
    initial begin
        d_i_ce      = 0;
        d_i_instr   = 32'h00000000;
        d_i_data_rd = 32'h00000000;
        #10;
        d_i_ce = 1;

        #10 d_i_instr = 32'h10220004; // BEQ $11, $11, 16
        #10 d_i_instr = 32'h0C400000; // JAL 0x000123 (test jump address)
        $finish;
    end

    // Monitor outputs - formatted for readability
    initial begin
        $display("==============================================================================================================");
        $display("Time(ns) | Instruction  | Opcode | Funct | RS | RT | RD |   IMM   |  JumpAddr  | RegWr | ALUSrc | MemWr | MemToReg");
        $display("--------------------------------------------------------------------------------------------------------------");
        $monitor("%8t | %h |  0x%02h  | 0x%02h | %2d | %2d | %2d | 0x%04h | 0x%06h |   %b   |   %b   |   %b   |    %b",
                 $time, d_i_instr, d_o_opcode, d_o_funct,
                 d_o_addr_rs, d_o_addr_rt, d_o_addr_rd, d_o_imm,
                 d_o_jal_addr, d_o_reg_wr, d_o_alu_src, d_o_memwrite, d_o_memtoreg);
        $display("==============================================================================================================");
    end

endmodule
