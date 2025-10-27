`ifndef MUX2_1_V
`define MUX2_1_V
`include "./source/header.vh"

module mux2_1 (
    a, b, regdst, out
);
    input regdst;
    input [`AWIDTH - 1 : 0] a, b;
    output [`AWIDTH - 1 : 0] out;

    assign out = (!regdst) ? a : b;
endmodule
`endif 