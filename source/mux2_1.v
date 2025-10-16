`ifndef MUX2_1_V
`define MUX2_1_V
`include "./source/header.vh"

module mux21 (
    a, b, opcode, out
);
    input [`AWIDTH - 1 : 0] a, b;
    input [`OPCODE_WIDTH - 1 : 0] opcode;
    output [`AWIDTH - 1 : 0] out;

    wire op_itype = (opcode == `LOAD || opcode == `ADDI || opcode == `ADDIU || 
                    opcode == `SLTI || opcode == `SLTIU || opcode == `ANDI ||
                    opcode == `ORI);
    wire op_rtype = (opcode == `RTYPE);

    assign out = (op_itype) ? a : (op_rtype) ? b : {`AWIDTH{1'b0}};
endmodule
`endif 