`include "./source/datapath.v"

module tb;
    parameter DWIDTH = 32;
    parameter IWIDTH = 32;
    parameter AWIDTH = 5;      
    parameter PC_WIDTH = 32;
    parameter DEPTH = 6;
    parameter AWIDTH_MEM = 32;

    reg d_clk, d_rst;
    reg d_i_ce;
    wire [`OPCODE_WIDTH - 1 : 0] ds_es_o_opcode;
    wire [PC_WIDTH - 1 : 0] fs_ds_o_pc;
    wire [DWIDTH - 1 : 0] write_back_data;

    datapath #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .IWIDTH(IWIDTH),
        .PC_WIDTH(PC_WIDTH),
        .DEPTH(DEPTH),
        .AWIDTH_MEM(AWIDTH_MEM)
    ) d (
        .d_clk(d_clk), 
        .d_rst(d_rst), 
        .d_i_ce(d_i_ce), 
        .ds_es_o_opcode(ds_es_o_opcode),
        .write_back_data(write_back_data),
        .fs_ds_o_pc(fs_ds_o_pc)
    );

    initial begin
        d_clk = 1'b0;
    end
    always #5 d_clk = ~d_clk;

    initial begin
        $dumpfile("./waveform/datapath.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin
            d_rst = 1'b0;
            repeat(counter) @(posedge d_clk);
            d_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge d_clk);
        d_i_ce = 1'b1;
        @(posedge d_clk);
        repeat(24) @(posedge d_clk);
        $finish;
    end

    initial begin  
        $monitor("%0t: PC=%0d, instr=%h, rs_data=%h, rt_data=%h, alu_out=%h, ds_es_o_opcode = %b", 
            $time, fs_ds_o_pc, d.fs_ds_o_instr, d.ds_es_o_data_rs, 
            d.ds_es_o_data_rt, write_back_data, ds_es_o_opcode);
    end
endmodule
