`ifndef VERIFY_V
`define VERIFY_V
`include "./source/imem.v"
`include "./source/program_counter.v"

module verify (
    v_clk, v_rst, v_i_ce, v_i_change_pc, v_i_pc, v_o_pc, v_o_instr, v_o_ce
);
    input v_clk, v_rst;
    input v_i_ce;
    input v_i_change_pc;
    input [`PC_WIDTH - 1 : 0] v_i_pc;
    output [`PC_WIDTH - 1 : 0] v_o_pc;
    output [`IWIDTH - 1 : 0] v_o_instr;
    output v_o_ce;

    wire p_i_o_ce;
    prog_counter pc (
        .pc_clk(v_clk), 
        .pc_rst(v_rst), 
        .pc_i_ce(v_i_ce), 
        .pc_i_change_pc(v_i_change_pc), 
        .pc_i_pc(v_i_pc), 
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
endmodule
`endif 