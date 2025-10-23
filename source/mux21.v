`ifndef MUX21_V
`define MUX21_V
`include "./source/header.vh"

module mux21 (
    a, b, c, d, e, f, opcode, funct, out_change_pc, out_alu_pc,
    out_alu_value
);
    input a, b;
    input [`PC_WIDTH - 1 : 0] c, d;
    input [`DWIDTH - 1 : 0] e, f;
    input [`FUNCT_WIDTH - 1 : 0] funct;
    input [`OPCODE_WIDTH - 1 : 0] opcode;
    output reg out_change_pc;
    output reg [`PC_WIDTH - 1 : 0] out_alu_pc;
    output reg [`DWIDTH - 1 : 0] out_alu_value;

    wire type_branch = (opcode == `BEQ) || (opcode == `BNE);
    wire type_jump = (opcode == `JAL) || (funct == `JR);

    always @(*) begin
        out_change_pc = 1'b0;
        out_alu_pc = {`PC_WIDTH{1'b0}};
        out_alu_value = {`DWIDTH{1'b0}};
        if (type_branch) begin
            out_change_pc = a;
            out_alu_pc = c;
            out_alu_value = e;
        end
        else if (type_jump) begin
            out_change_pc = b;
            out_alu_pc = d;
            out_alu_value = f;
        end
    end
endmodule
`endif 