`include "./source/program_counter.v"

module tb;
    reg pc_clk, pc_rst;
    reg pc_i_ce;
    reg pc_i_change_pc;
    reg [`PC_WIDTH - 1 : 0] pc_i_pc;
    wire [`PC_WIDTH - 1 : 0] pc_o_pc;
    wire pc_o_ce;

    prog_counter pc (
        .pc_clk(pc_clk), 
        .pc_rst(pc_rst), 
        .pc_i_ce(pc_i_ce), 
        .pc_i_change_pc(pc_i_change_pc), 
        .pc_i_pc(pc_i_pc), 
        .pc_o_pc(pc_o_pc), 
        .pc_o_ce(pc_o_ce)
    );

    initial begin
        pc_clk = 1'b0;
    end
    always #5 pc_clk = ~pc_clk;

    initial begin
        $dumpfile("./waveform/pc.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin 
            pc_rst = 1'b0;
            repeat(counter) @(posedge pc_clk);
            pc_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge pc_clk);
        pc_i_ce = 1'b1;
        repeat(20) @(posedge pc_clk);
        // pc_i_change_pc = 1'b1;
        // pc_i_pc = 10;
        // @(posedge pc_clk);
        // pc_i_change_pc = 1'b0;
        #200; $finish;
    end

    initial begin
        $monitor($time, " ", "pc_o_ce = %b, pc_o_pc = %d", pc_o_ce, pc_o_pc);
    end
endmodule