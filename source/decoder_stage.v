`ifndef DECODER_STAGE_V
`define DECODER_STAGE_V
`include "./source/decoder.v"
`include "./source/register.v"
`include "./source/header.vh"
`include "./source/branch.v"
module decoder_stage (
    ds_clk, ds_rst, ds_i_ce, ds_i_data_rd, ds_i_addr_rd, ds_i_instr, ds_i_reg_wr,
    ds_o_opcode, ds_o_funct, ds_o_data_rs, ds_o_data_rt, ds_o_imm, ds_o_ce, ds_o_memwrite,
    ds_o_alu_src, ds_o_addr_rs, ds_o_addr_rt, ds_o_addr_rd, ds_o_reg_wr, ds_o_memtoreg,
    ds_o_jal, ds_o_jal_addr, ds_o_branch, ds_o_jr, ds_o_alu_value
);
    input ds_clk, ds_rst;
    input ds_i_ce;
    input [`DWIDTH - 1 : 0] ds_i_data_rd;
    input [`AWIDTH - 1 : 0] ds_i_addr_rd;
    input ds_i_reg_wr;
    // input [`PC_WIDTH - 1 : 0] ds_i_pc;
    input [`IWIDTH - 1 : 0] ds_i_instr;
    output [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    output [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    output [`DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    output [`AWIDTH - 1 : 0] ds_o_addr_rs, ds_o_addr_rt;
    output [`IMM_WIDTH - 1 : 0] ds_o_imm;
    output [`AWIDTH - 1 : 0] ds_o_addr_rd;
    output ds_o_ce;
    output ds_o_alu_src;
    output ds_o_reg_wr;
    output ds_o_branch;
    // output ds_o_memread; 
    output ds_o_memwrite;
    output ds_o_memtoreg;
    output ds_o_jal;
    output [`JUMP_WIDTH - 1 : 0] ds_o_jal_addr;
    // output ds_o_change_pc;
    // output [`PC_WIDTH - 1 : 0] ds_o_alu_pc;
    output [`DWIDTH - 1 : 0] ds_o_alu_value;
    output ds_o_jr;
    // wire d_r_o_reg_dst;
    
    decoder d (
        .d_i_ce(ds_i_ce), 
        .d_i_instr(ds_i_instr), 
        .d_o_opcode(ds_o_opcode), 
        .d_o_funct(ds_o_funct), 
        .d_o_addr_rs(ds_o_addr_rs), 
        .d_o_addr_rt(ds_o_addr_rt), 
        .d_o_addr_rd(ds_o_addr_rd), 
        .d_o_imm(ds_o_imm),
        .d_o_ce(ds_o_ce),
        // .d_o_reg_dst(d_r_o_reg_dst),
        .d_o_branch(ds_o_branch),
        .d_o_alu_src(ds_o_alu_src),
        .d_o_reg_wr(ds_o_reg_wr),
        // .d_o_memread(ds_o_memread),
        .d_o_memwrite(ds_o_memwrite),
        .d_o_memtoreg(ds_o_memtoreg),
        .d_o_jal(ds_o_jal),
        .d_o_jal_addr(ds_o_jal_addr),
        .d_o_jr(ds_o_jr)
    );

    // wire [`AWIDTH - 1 : 0] write_register;
    // assign write_register = (d_r_o_reg_dst) ? ds_o_addr_rd : ds_o_addr_rt;

    register r (
        .r_clk(ds_clk), 
        .r_rst(ds_rst), 
        .r_wr_en(ds_i_reg_wr), 
        .r_data_in(ds_i_data_rd), 
        .r_addr_in(ds_i_addr_rd), 
        .r_addr_out1(ds_o_addr_rs), 
        .r_addr_out2(ds_o_addr_rt),
        .r_data_out1(ds_o_data_rs), 
        .r_data_out2(ds_o_data_rt) 
    );

    // wire change_pc;
    // wire [`PC_WIDTH - 1 : 0] alu_pc;
    // branch b (
    //     .b_i_opcode(ds_o_opcode), 
    //     .b_i_data_rs(ds_o_data_rs), 
    //     .b_i_data_rt(ds_o_data_rt), 
    //     .b_i_pc(ds_i_pc), 
    //     .b_i_imm(ds_o_imm), 
    //     .b_o_change_pc(change_pc), 
    //     .b_o_alu_pc(alu_pc),
    //     .b_o_alu_value(ds_o_alu_value)
    // );

    // wire take_beq = ds_o_branch && (ds_o_data_rs == ds_o_data_rt);
    // wire take_bne = ds_o_branch && !(ds_o_data_rs == ds_o_data_rt);
    // wire take_branch = ds_i_ce && (take_beq || take_bne);
    // assign ds_o_change_pc = take_branch & change_pc;
    // assign ds_o_alu_pc = (take_branch && change_pc) ? alu_pc : {`PC_WIDTH{1'b0}};
endmodule
`endif 