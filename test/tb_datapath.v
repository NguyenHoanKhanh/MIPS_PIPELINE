`include "./source/datapath.v"

module tb;
    reg d_clk, d_rst;
    reg d_i_ce;
    wire [`PC_WIDTH - 1 : 0] im_ds_o_pc;
    wire [`DWIDTH - 1 : 0] write_back_data;

    datapath d (
        .d_clk(d_clk), 
        .d_rst(d_rst), 
        .d_i_ce(d_i_ce), 
        .write_back_data(write_back_data),
        .im_ds_o_pc(im_ds_o_pc)
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
        repeat(24) @(posedge d_clk);
        $finish;
    end

    initial begin  
        $monitor("%0t: PC = %0d, instr = %h, alu_out = %d", 
            $time, im_ds_o_pc, d.im_ds_o_instr, write_back_data);
    end
endmodule
