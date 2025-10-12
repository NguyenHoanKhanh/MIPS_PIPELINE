`timescale 1ns/1ps
`include "./source/decoder.v"

module tb_decoder;
    reg  d_i_ce;
    reg  [`IWIDTH - 1 : 0] d_i_instr;
    reg  [`DWIDTH - 1 : 0] d_i_data_rd;
    wire [`OPCODE_WIDTH - 1 : 0] d_o_opcode;
    wire [`FUNCT_WIDTH  - 1 : 0] d_o_funct;
    wire [`AWIDTH - 1 : 0] d_o_addr_rs, d_o_addr_rt;
    wire [`AWIDTH - 1 : 0] d_o_addr_rd;
    wire [`DWIDTH - 1 : 0] d_o_data_rs, d_o_data_rt;
    wire [`IMM_WIDTH - 1 : 0] d_o_imm;
    wire d_o_reg_dst;
    wire d_o_reg_wr;
    wire d_o_alu_src;
    wire d_o_branch;
    wire d_o_memread, d_o_memwrite;
    wire d_o_memtoreg;
    wire d_o_ce;  

    // Instantiate decoder
    decode dut (
        .d_i_ce(d_i_ce), 
        .d_i_instr(d_i_instr), 
        .d_o_opcode(d_o_opcode), 
        .d_o_funct(d_o_funct), 
        .d_o_addr_rs(d_o_addr_rs), 
        .d_o_addr_rt(d_o_addr_rt),
        .d_o_addr_rd(d_o_addr_rd), 
        .d_o_imm(d_o_imm), 
        .d_o_ce(d_o_ce),
        .d_o_reg_dst(d_o_reg_dst),
        .d_o_branch(d_o_branch),
        .d_o_alu_src(d_o_alu_src),
        .d_o_reg_wr(d_o_reg_wr),
        .d_o_memread(d_o_memread),
        .d_o_memwrite(d_o_memwrite),
        .d_o_memtoreg(d_o_memtoreg)
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

        // 5 instructions (ví dụ)
        // @(posedge d_clk) d_i_instr = 32'h00430820; // ADD  $1,$2,$3
        // @(posedge d_clk) d_i_instr = 32'h00A62022; // SUB  $4,$5,$6
        // @(posedge d_clk) d_i_instr = 32'h01093824; // AND  $7,$8,$9
        // @(posedge d_clk) d_i_instr = 32'h016C5025; // OR   $10,$11,$12
        // @(posedge d_clk) d_i_instr = 32'h01CF6826; // XOR  $13,$14,$15
        // @(posedge d_clk) d_i_instr = 32'h10410064; //ADDI $1, $2, 100
        #10 d_i_instr = 32'h0D6B0010; // BEQ $11, $11, 16
        $finish;
    end

    // Monitor outputs (thêm MemRead/MemWrite/MemToReg)
    initial begin
        $display("Time\t Instr\t\tOpcode\tFunct\tRS\tRT\tRD\tIMM\tRegDst\tRegWr\tBranch\tALUSrc\tMemRead\tMemWrite MemToReg");
        $monitor("%0t\t%h\t%0d\t%0b\t%0d\t%0d\t%0d\t%0d\t%b\t%b\t%b\t%b\t%b\t%b\t %b",
                $time, d_i_instr, d_o_opcode, d_o_funct,
                d_o_addr_rs, d_o_addr_rt, d_o_addr_rd, d_o_imm,
                d_o_reg_dst, d_o_reg_wr, d_o_branch, d_o_alu_src,
                d_o_memread, d_o_memwrite, d_o_memtoreg);
    end

endmodule
