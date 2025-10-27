`ifndef MUX3_1_V
`define MUX3_1_V
`include "./source/header.vh"

module mux31 (
    a, b, c, sel, data_out
);
    input [1 : 0] sel;
    input [`DWIDTH - 1 : 0] a, b, c;
    output [`DWIDTH - 1 : 0] data_out;

    assign data_out = (sel == 2'd0) ? a : (sel == 2'd1) ? b : 
                        (sel == 2'd2) ? c : {`DWIDTH{1'b0}};
endmodule
`endif