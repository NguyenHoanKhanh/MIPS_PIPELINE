`include "./source/verify.v"

module tb;
    reg v_clk, v_rst;
    reg v_i_ce;
    reg v_i_change_pc;
    reg [`PC_WIDTH - 1 : 0] v_i_pc;
    wire [`IWIDTH - 1 : 0] v_o_instr;
    wire [`PC_WIDTH - 1 : 0] v_o_pc;
    wire v_o_ce;
    verify v (
        .v_clk(v_clk), 
        .v_rst(v_rst), 
        .v_i_ce(v_i_ce), 
        .v_i_change_pc(v_i_change_pc), 
        .v_i_pc(v_i_pc), 
        .v_o_pc(v_o_pc), 
        .v_o_instr(v_o_instr), 
        .v_o_ce(v_o_ce)
    );

    initial begin
        v_clk = 1'b0;
        v_i_ce = 1'b0;
    end
    always #5 v_clk = ~v_clk;

    initial begin
        $dumpfile("./waveform/verify.vcd");
        $dumpvars(0, tb);
    end

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
        #100; $finish;
        $finish;
    end

    initial begin
        $monitor($time, " ", "v_o_instr = %h, v_o_pc = %d, v_o_ce = %b",
        v_o_instr, v_o_pc, v_o_ce);
    end
endmodule