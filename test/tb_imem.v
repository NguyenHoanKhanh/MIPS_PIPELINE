`include "./source/imem.v"

module tb;
    reg im_clk, im_rst;
    reg im_i_ce;
    reg [`PC_WIDTH - 1 : 0] im_i_address;
    wire [`IWIDTH - 1 : 0] im_o_instr;
    wire im_o_ce;

    imem i_m (
        .im_clk(im_clk), 
        .im_rst(im_rst), 
        .im_i_ce(im_i_ce), 
        .im_i_address(im_i_address), 
        .im_o_instr(im_o_instr), 
        .im_o_ce(im_o_ce)
    );

    initial begin
        im_clk = 1'b0;
    end
    always #5 im_clk = ~im_clk;

    task reset (input integer counter);
        begin
            im_rst = 1'b0;
            repeat(counter) @(posedge im_clk);
            im_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge im_clk);
        im_i_ce = 1'b1;
        im_i_address = 32'd0;
        @(posedge im_clk);
        im_i_address = 32'd4;
        #20; $finish;
    end

    initial begin
        $monitor($time, " ", "im_i_address = %d, im_o_instr = %h, im_o_ce = %b", im_i_address, im_o_instr, im_o_ce);
    end
endmodule