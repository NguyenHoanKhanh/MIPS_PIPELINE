`ifndef ADDER_V
`define ADDER_V
`include "./source/header.vh"
`include "./source/treat_jal.v"
module adder (
    i_pc, i_imm, i_branch, i_opcode, i_es_opcode, i_es_o_pc, i_es_o_change_pc, 
    i_data_r1, i_data_r2, o_pc, o_compare
);
    input i_branch;
    input [`OPCODE_WIDTH - 1 : 0] i_opcode, i_es_opcode;
    input [`PC_WIDTH - 1 : 0] i_pc;
    input [`PC_WIDTH - 1 : 0] i_es_o_pc;
    input i_es_o_change_pc;
    input [`IMM_WIDTH - 1 : 0] i_imm;
    input [`DWIDTH - 1 : 0] i_data_r1, i_data_r2;
    output reg [`PC_WIDTH - 1 : 0] o_pc;
    output reg o_compare;
    wire [`DWIDTH - 1 : 0] o_imm = {{(`DWIDTH - `IMM_WIDTH){i_imm[`IMM_WIDTH - 1]}}, i_imm};    

    always @(*) begin
        o_compare = 1'b0;
        o_pc = {`PC_WIDTH{1'b0}};
        if (i_branch) begin
            o_pc = i_pc + o_imm;
            o_compare = ((i_opcode == `BEQ) && (i_data_r1 == i_data_r2)) ?  1'b1
                        : ((i_opcode == `BNE) && (i_data_r1 != i_data_r2)) ? 1'b1 
                        : 1'b0;
        end
        else begin
            o_compare = i_es_o_change_pc;
            o_pc = i_es_o_pc;
        end
    end
endmodule
`endif 