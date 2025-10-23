`ifndef VERIFY_V
`define VERIFY_V
`include "./source/imem.v"
`include "./source/program_counter.v"
`include "./source/decoder_stage.v"
`include "./source/execute_stage.v"
`include "./source/mux21.v"
module verify (
    v_clk, v_rst, v_i_ce, v_o_instr, v_o_pc, es_o_alu_value, es_o_ce
);
    input v_clk, v_rst;
    input v_i_ce;
    output [`PC_WIDTH - 1 : 0] v_o_pc;
    output [`IWIDTH - 1 : 0] v_o_instr;
    output [`DWIDTH - 1 : 0] es_o_alu_value;
    output es_o_ce;

    wire p_i_o_ce;
    prog_counter pc (
        .pc_clk(v_clk), 
        .pc_rst(v_rst), 
        .pc_i_ce(v_i_ce), 
        .pc_i_change_pc(es_o_change_pc), 
        .pc_i_pc(es_o_alu_pc), 
        .pc_o_pc(v_o_pc), 
        .pc_o_ce(p_i_o_ce)
    );

    imem i_m (
        .im_clk(v_clk), 
        .im_rst(v_rst), 
        .im_i_ce(p_i_o_ce), 
        .im_i_address(v_o_pc), 
        .im_o_instr(v_o_instr), 
        .im_o_ce(v_o_ce)
    );

    wire [`DWIDTH - 1 : 0] ds_i_data_rd;
    wire [`AWIDTH - 1 : 0] ds_i_addr_rd;
    wire ds_i_reg_wr;
    wire [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    wire [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    wire [`DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    wire [`IMM_WIDTH - 1 : 0] ds_o_imm;
    wire ds_o_ce;
    wire ds_o_memwrite, ds_o_alu_src, ds_o_reg_wr, ds_o_memtoreg;
    wire [`AWIDTH - 1 : 0] ds_o_addr_rd, ds_o_addr_rs, ds_o_addr_rt;
    wire ds_o_jal, ds_o_jr;
    wire [`JUMP_WIDTH - 1 : 0] ds_o_jal_addr;
    wire ds_o_change_pc;
    wire [`PC_WIDTH - 1 : 0] ds_o_alu_pc;
    wire [`DWIDTH - 1 : 0] ds_o_alu_value;
    decoder_stage ds (
        .ds_clk(v_clk), 
        .ds_rst(v_rst), 
        .ds_i_ce(v_o_ce), 
        .ds_i_data_rd(ds_i_data_rd), 
        .ds_i_addr_rd(ds_i_addr_rd), 
        .ds_i_instr(v_o_instr), 
        .ds_i_reg_wr(ds_i_reg_wr),
        // .ds_i_pc(v_o_pc),
        .ds_o_opcode(ds_o_opcode), 
        .ds_o_funct(ds_o_funct), 
        .ds_o_data_rs(ds_o_data_rs), 
        .ds_o_data_rt(ds_o_data_rt), 
        .ds_o_imm(ds_o_imm), 
        .ds_o_ce(ds_o_ce), 
        .ds_o_memwrite(ds_o_memwrite),
        .ds_o_alu_src(ds_o_alu_src), 
        .ds_o_addr_rs(ds_o_addr_rs), 
        .ds_o_addr_rt(ds_o_addr_rt), 
        .ds_o_addr_rd(ds_o_addr_rd), 
        .ds_o_reg_wr(ds_o_reg_wr), 
        .ds_o_memtoreg(ds_o_memtoreg),
        .ds_o_jal_addr(ds_o_jal_addr), 
        .ds_o_jal(ds_o_jal),
        .ds_o_jr(ds_o_jr)
        // .ds_o_change_pc(ds_o_change_pc)
        // .ds_o_alu_pc(ds_o_alu_pc),
        // .ds_o_alu_value(ds_o_alu_value)
    );

    wire [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    wire es_o_change_pc;
    wire [`PC_WIDTH - 1 : 0] es_o_ra;
    wire [`PC_WIDTH - 1 : 0] es_o_alu_pc;

    execute es (
        .es_i_ce(ds_o_ce), 
        .es_i_pc(v_o_pc), 
        .es_i_jal(ds_o_jal), 
        .es_i_jal_addr(ds_o_jal_addr),
        .es_i_jr(ds_o_jr), 
        .es_i_alu_src(ds_o_alu_src), 
        .es_i_imm(ds_o_imm), 
        .es_i_alu_op(ds_o_opcode), 
        .es_i_alu_funct(ds_o_funct),
        .es_i_data_rs(ds_o_data_rs), 
        .es_i_data_rt(ds_o_data_rt), 
        .es_o_alu_value(es_o_alu_value), 
        .es_o_ce(es_o_ce), 
        .es_o_opcode(es_o_opcode), 
        .es_o_change_pc(es_o_change_pc), 
        .es_o_alu_pc(es_o_alu_pc)
    );

    // wire mx_o_change_pc;
    // wire [`PC_WIDTH - 1 : 0] mx_o_alu_pc;
    // mux21 m21 (
    //     .a(ds_o_change_pc), 
    //     .b(es_o_change_pc), 
    //     .c(ds_o_alu_pc), 
    //     .d(es_o_alu_pc), 
    //     .opcode(ds_o_opcode), 
    //     .funct(ds_o_funct), 
    //     .out_change_pc(mx_o_change_pc), 
    //     .out_alu_pc(mx_o_alu_pc)
    // );
endmodule
`endif 