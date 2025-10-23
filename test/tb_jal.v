`include "./source/treat_jal.v"
module tb;
    reg tj_i_jal;
    reg [`PC_WIDTH - 1 : 0] tj_i_pc;
    reg [`JUMP_WIDTH - 1 : 0] tj_i_jal_addr;
    wire [`PC_WIDTH - 1 : 0] tj_o_pc;
    wire [`PC_WIDTH - 1 : 0] tj_o_ra;

    treat_jal tj (
        .tj_i_jal(tj_i_jal),
        .tj_i_pc(tj_i_pc), 
        .tj_i_jal_addr(tj_i_jal_addr), 
        .tj_o_pc(tj_o_pc), 
        .tj_o_ra(tj_o_ra)
    );

    initial begin
        tj_i_jal = 1'b0;
        tj_i_jal_addr = {`JUMP_WIDTH{1'b0}};
        tj_i_pc = {`PC_WIDTH{1'b0}};
    end

    initial begin
        #1;
        tj_i_jal = 1'b1;
        tj_i_pc = 5;
        tj_i_jal_addr = 10;
        #10;
        #20; $finish;
    end

    initial begin
        $monitor($time, " ", "tj_o_pc = %d, tj_o_ra = %d", tj_o_pc, tj_o_ra);
    end
endmodule