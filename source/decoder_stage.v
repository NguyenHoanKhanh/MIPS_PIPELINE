`ifndef DECODER_STAGE_V
`define DECODER_STAGE_V
`include "./source/decoder.v"
`include "./source/register.v"

module decoder_stage #(
    parameter AWIDTH = 5,
    parameter DWIDTH = 32,
    parameter IWIDTH = 32,
    parameter IMM_WIDTH = 16
)(
    ds_clk, ds_rst, ds_i_ce, ds_i_data_rd, ds_i_instr, ds_o_opcode, 
    ds_o_funct, ds_o_data_rs, ds_o_data_rt, ds_o_imm, ds_o_ce, ds_o_branch,
    ds_o_alu_src, ds_o_memread, ds_o_memwrite, ds_o_memtoreg
);
    input ds_clk, ds_rst;
    input ds_i_ce;
    input [DWIDTH - 1 : 0] ds_i_data_rd;
    input [IWIDTH - 1 : 0] ds_i_instr;
    output [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    output [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    output [DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    output [IMM_WIDTH - 1 : 0] ds_o_imm;
    output ds_o_ce;
    output ds_o_branch;
    output ds_o_alu_src;
    output ds_o_memread, ds_o_memwrite;
    output ds_o_memtoreg;
    wire d_r_o_reg_dst;
    wire d_r_o_reg_wr;
    wire [AWIDTH - 1 : 0] d_o_addr_rs, d_o_addr_rt;
    wire [AWIDTH - 1 : 0] ds_i_addr_rd;
    
    decode #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .IWIDTH(IWIDTH),
        .IMM_WIDTH(IMM_WIDTH)
    ) d (
        .d_clk(ds_clk), 
        .d_rst(ds_rst), 
        .d_i_ce(ds_i_ce), 
        .d_i_instr(ds_i_instr), 
        .d_o_opcode(ds_o_opcode), 
        .d_o_funct(ds_o_funct), 
        .d_o_addr_rs(d_o_addr_rs), 
        .d_o_addr_rt(d_o_addr_rt), 
        .d_o_addr_rd(ds_i_addr_rd), 
        .d_o_imm(ds_o_imm),
        .d_o_ce(ds_o_ce),
        .d_o_reg_dst(d_r_o_reg_dst),
        .d_o_branch(ds_o_branch),
        .d_o_alu_src(ds_o_alu_src),
        .d_o_reg_wr(d_r_o_reg_wr),
        .d_o_memread(ds_o_memread),
        .d_o_memwrite(ds_o_memwrite),
        .d_o_memtoreg(ds_o_memtoreg)
    );

    wire [AWIDTH - 1 : 0] write_register;
    assign write_register = (d_r_o_reg_dst) ? ds_i_addr_rd : d_o_addr_rt;

    register #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH)
    ) r (
        .r_clk(ds_clk), 
        .r_rst(ds_rst), 
        .r_wr_en(d_r_o_reg_wr), 
        .r_data_in(ds_i_data_rd), 
        .r_addr_in(write_register), 
        .r_addr_out1(d_o_addr_rs), 
        .r_addr_out2(d_o_addr_rt),
        .r_data_out1(ds_o_data_rs), 
        .r_data_out2(ds_o_data_rt) 
    );
endmodule
`endif 