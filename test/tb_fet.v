`include "./source/fetch.v"

module tb;
    reg f_clk, f_rst;
    reg f_i_ce;
    reg [`PC_WIDTH - 1 : 0] f_i_address;
    wire [`IWIDTH - 1 : 0] f_o_instr;
    wire f_o_ce;

    instruction_fetch i_f (
        .f_clk(f_clk), 
        .f_rst(f_rst), 
        .f_i_ce(f_i_ce), 
        .f_i_address(f_i_address), 
        .f_o_instr(f_o_instr), 
        .f_o_ce(f_o_ce)
    );

    initial begin
        f_i_address = {`PC_WIDTH{1'b0}};
        f_i_ce = 1'b0;
        f_clk = 1'b0;
    end
    always #5 f_clk = ~f_clk;

    initial begin
        $dumpfile("./waveform/fet.vcd");
        $dumpvars(0, tb);
    end

    task reset (input integer counter);
        begin   
            f_rst = 1'b0;
            repeat(counter) @(posedge f_clk);
            f_rst = 1'b1;
        end
    endtask

    initial begin
        reset(2);
        @(posedge f_clk);
        // set PC=0 rồi bật CE
        f_i_address = 32'd0;
        f_i_ce = 1'b1;
        @(posedge f_clk); // -> f_o_instr = instr[0] (08E80014)

        // set PC=4
        f_i_address = 32'd4;
        @(posedge f_clk); // -> f_o_instr = instr[1] (04E60014)

        @(posedge f_clk);
        $finish;
    end
    initial begin
        $monitor($time, " ", "f_i_address = %d, f_o_instr = %h, f_o_ce = %b", f_i_address, f_o_instr, f_o_ce);
    end
endmodule