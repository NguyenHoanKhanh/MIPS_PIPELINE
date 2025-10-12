`include "./source/instruction_fetch.v"
module tb;
    reg f_i_ce;
    wire [`IWIDTH - 1 : 0] f_o_instr;
    wire f_o_ce;
    wire f_o_valid;
    integer i;

    instruction_fetch f (
        .f_i_ce(f_i_ce),
        .f_o_instr(f_o_instr), 
        .f_o_ce(f_o_ce)
    );

    initial begin
        f_i_ce = 1'b0;
    end

    initial begin
        $dumpfile("./waveform/fetch.vcd");
        $dumpvars(0, tb);
    end

    task display (input integer counter);
        begin
            f_i_ce = 1'b1;
            for (i = 0; i < counter; i = i + 1) begin
                #10;
                $display($time, " ", "instr = %h, last = %b, syn = %b, ack = %b, ce = %b", f_o_instr, f.f_i_last, f.f_o_syn, f.f_i_ack, f_o_ce); 
            end
            f_i_ce = 1'b0;
        end
    endtask

    initial begin
        display(8);
        repeat(10) #10;
        $finish;
    end
endmodule