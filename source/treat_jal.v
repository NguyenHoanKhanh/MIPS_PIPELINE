`ifndef TREAT_JAL_V
`define TREAT_JAL_V
`include "./source/header.vh"

module treat_jal (
    tj_i_jal, tj_i_pc, tj_i_jal_addr, tj_o_pc, tj_o_ra, tj_o_change_pc
);
    input tj_i_jal;
    input [`JUMP_WIDTH - 1 : 0] tj_i_jal_addr;
    input [`PC_WIDTH - 1 : 0] tj_i_pc;
    output reg [`PC_WIDTH - 1 : 0] tj_o_pc;
    output reg [`PC_WIDTH - 1 : 0] tj_o_ra;
    output reg tj_o_change_pc;

    wire [`PC_WIDTH - 1 : 0] temp_jumpaddr = {tj_i_pc[31 : 28], tj_i_jal_addr, 2'b0};
    always @(*) begin
        tj_o_ra = {`PC_WIDTH{1'b0}};
        tj_o_pc = {`PC_WIDTH{1'b0}};
        tj_o_change_pc = 1'b0;
        if (tj_i_jal) begin
            tj_o_pc = temp_jumpaddr;
            tj_o_ra = tj_i_pc + 4;
            tj_o_change_pc = 1'b1;
        end
        else begin
            tj_o_change_pc = 1'b0;
            tj_o_pc = {`PC_WIDTH{1'b0}};
            tj_o_ra = {`PC_WIDTH{1'b0}};
        end
    end
endmodule
`endif