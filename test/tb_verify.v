`include "./source/verify.v"

module tb;
    parameter PC_WIDTH = 32;
    parameter IWIDTH = 32;
    parameter DEPTH = 6;
    parameter AWIDTH = 5;
    parameter DWIDTH = 32;
    parameter IMM_WIDTH = 16;
    
    reg v_clk, v_rst;
    reg v_i_ce;
    wire [IWIDTH - 1 : 0] v_o_instr;
    wire [PC_WIDTH - 1 : 0] f_e_o_pc;
    wire [DWIDTH - 1 : 0] v_o_alu_value;
    wire [`OPCODE_WIDTH - 1 : 0] v_o_opcode;
    wire [`FUNCT_WIDTH - 1 : 0] v_o_funct; 
    wire v_o_zero, v_o_ce;

    verify #(
        .PC_WIDTH(PC_WIDTH),
        .IWIDTH(IWIDTH),
        .DEPTH(DEPTH),
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .IMM_WIDTH(IMM_WIDTH)
    ) v (
        .v_clk(v_clk), 
        .v_rst(v_rst), 
        .v_i_ce(v_i_ce), 
        .v_o_instr(v_o_instr), 
        .f_e_o_pc(f_e_o_pc), 
        .v_o_alu_value(v_o_alu_value), 
        .v_o_opcode(v_o_opcode), 
        .v_o_funct(v_o_funct), 
        .v_o_zero(v_o_zero), 
        .v_o_ce(v_o_ce)        
    );

    initial begin
        v_clk = 1'b0;
        v_i_ce = 1'b0;
    end
    always #5 v_clk = ~v_clk;

    task reset (input integer counter);
        begin
            v_rst = 1'b0;
            repeat(counter) @(posedge v_clk);
            v_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge v_clk);
        v_i_ce = 1'b1;
        repeat(15) @(posedge v_clk);
        $finish;
    end

    initial begin
        $monitor($time, " ", "v_o_instr = %h, f_e_o_pc = %d, v_o_opcode = %d, v_o_funct = %d, v_o_alu_value = %d, v_o_zero = %b, v_o_ce = %b",
        v_o_instr, f_e_o_pc, v_o_opcode, v_o_funct, v_o_alu_value, v_o_zero, v_o_ce);
    end
endmodule