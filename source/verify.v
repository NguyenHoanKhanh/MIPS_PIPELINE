`ifndef VERIFY_V
`define VERIFY_V
`include "./source/instruction_fetch.v"
`include "./source/decoder_stage.v"
`include "./source/execute_stage.v"

module verify #(
    parameter PC_WIDTH = 32,
    parameter IWIDTH = 32,
    parameter DEPTH = 6,
    parameter AWIDTH = 5,
    parameter DWIDTH = 32,
    parameter IMM_WIDTH = 16
) (
    v_clk, v_rst, v_i_ce, v_o_instr, f_e_o_pc, v_o_alu_value, v_o_opcode, v_o_funct, 
    v_o_zero, v_o_ce
);
    input v_clk, v_rst;
    input v_i_ce;
    output [IWIDTH - 1 : 0] v_o_instr;
    output [PC_WIDTH - 1 : 0] f_e_o_pc;
    output [DWIDTH - 1 : 0] v_o_alu_value;
    output [`OPCODE_WIDTH - 1 : 0] v_o_opcode;
    output [`FUNCT_WIDTH - 1 : 0] v_o_funct;
    output v_o_zero;
    output v_o_ce;
    
    wire f_i_change_pc;
    wire [PC_WIDTH - 1 : 0] f_i_pc;
    wire f_d_o_ce;

    instruction_fetch #(
        .PC_WIDTH(PC_WIDTH),
        .IWIDTH(IWIDTH),
        .DEPTH(DEPTH)
    ) i_f (
        .f_clk(v_clk), 
        .f_rst(v_rst), 
        .f_i_ce(v_i_ce), 
        .f_i_change_pc(v_o_change_pc), 
        .f_i_pc(v_o_alu_pc), 
        .f_o_instr(v_o_instr), 
        .f_o_pc(f_e_o_pc), 
        .f_o_ce(f_d_o_ce)
    );

    wire [`OPCODE_WIDTH - 1 : 0] d_e_o_opcode;
    wire [`FUNCT_WIDTH - 1 : 0] d_e_o_funct;
    wire [DWIDTH - 1 : 0] d_e_o_data_rs, d_e_o_data_rt;
    wire [IMM_WIDTH - 1 : 0] d_e_o_imm;
    wire d_e_o_ce;
    wire d_e_o_branch;
    wire d_e_o_alu_src;
    wire v_o_memread, v_o_memwrite;
    wire v_o_memtoreg;
    wire [DWIDTH - 1 : 0] ds_i_data_rd;
    decoder_stage #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .IWIDTH(IWIDTH),
        .IMM_WIDTH(IMM_WIDTH)
    ) d_s (
        .ds_clk(v_clk), 
        .ds_rst(v_rst), 
        .ds_i_ce(f_d_o_ce), 
        .ds_i_data_rd(ds_i_data_rd), 
        .ds_i_instr(v_o_instr), 
        .ds_o_opcode(d_e_o_opcode), 
        .ds_o_funct(d_e_o_funct), 
        .ds_o_data_rs(d_e_o_data_rs), 
        .ds_o_data_rt(d_e_o_data_rt), 
        .ds_o_imm(d_e_o_imm), 
        .ds_o_ce(d_e_o_ce), 
        .ds_o_branch(d_e_o_branch),
        .ds_o_alu_src(d_e_o_alu_src), 
        .ds_o_memread(v_o_memread), 
        .ds_o_memwrite(v_o_memwrite), 
        .ds_o_memtoreg(v_o_memtoreg)
    );

    wire [PC_WIDTH - 1 : 0] v_o_alu_pc;
    wire v_o_change_pc;
    execute #(
        .DWIDTH(DWIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .PC_WIDTH(PC_WIDTH)
    ) e_s (
        .es_i_ce(d_e_o_ce), 
        .es_i_branch(d_e_o_branch), 
        .es_i_pc(f_e_o_pc), 
        .es_i_alu_src(d_e_o_alu_src), 
        .es_i_imm(d_e_o_imm), 
        .es_i_alu_op(d_e_o_opcode), 
        .es_i_alu_funct(d_e_o_funct),
        .es_i_data_rs(d_e_o_data_rs),
        .es_i_data_rt(d_e_o_data_rt), 
        .es_o_alu_value(v_o_alu_value), 
        .es_o_opcode(v_o_opcode), 
        .es_o_funct(v_o_funct), 
        .es_o_zero(v_o_zero), 
        .es_o_ce(v_o_ce), 
        .es_o_alu_pc(v_o_alu_pc), 
        .es_o_change_pc(v_o_change_pc)
    );
endmodule
`endif 