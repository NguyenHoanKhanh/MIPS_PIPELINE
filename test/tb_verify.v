`include "./source/verify.v"

module tb;
    reg v_clk, v_rst;
    reg v_i_ce;
    wire [`IWIDTH - 1 : 0] v_o_instr;
    wire [`PC_WIDTH - 1 : 0] v_o_pc;
    wire [`DWIDTH - 1 : 0] es_o_alu_value;
    wire es_o_ce;
    verify v (
        v_clk, v_rst, v_i_ce, v_o_instr, v_o_pc, es_o_alu_value, es_o_ce
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
        $monitor($time, " ", "v_o_instr = %h, v_o_pc = %d, ds_o_jal = %b, ds_o_jal_addr = %d, ds_o_jr = %b, r_data_in = %d, r_addr_in = %d, r_addr_out1 = %d, r_data_out1 = %d, d_o_reg_wr = %b, es_o_alu_value = %d",
        v_o_instr, v_o_pc, v.ds_o_jal, v.ds_o_jal_addr, v.ds_o_jr, v.ds.r.r_data_in, v.ds.r.r_addr_in, v.ds.r.r_addr_out1, v.ds.r.r_data_out1, v.ds.d.d_o_reg_wr, v.es_o_alu_value);
    end
endmodule