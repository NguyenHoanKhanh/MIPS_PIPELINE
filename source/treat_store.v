`ifndef TREAT_STORE_V
`define TREAT_STORE_V
`include "./source/header.vh"

module treatstore (
    ts_i_opcode, ts_i_store_data, ts_o_store_data, ts_o_store_mask
);
    input [`OPCODE_WIDTH - 1 : 0] ts_i_opcode;
    input [`DWIDTH - 1 : 0] ts_i_store_data;
    output reg [`DWIDTH - 1 : 0] ts_o_store_data;
    output reg [3 : 0] ts_o_store_mask;

    always @(*) begin
        ts_o_store_data = {`DWIDTH{1'b0}};
        ts_o_store_mask = {4{1'b0}};
        case (ts_i_opcode)
            `STORE : begin
                ts_o_store_mask = 4'b1111;
                ts_o_store_data = ts_i_store_data;
            end
            `STORE_BYTE : begin
                ts_o_store_mask = 4'b0001;
                ts_o_store_data = {{24{1'b0}}, ts_i_store_data[7 : 0]};
            end
            `STORE_HALF : begin
                ts_o_store_mask = 4'b0011;
                ts_o_store_data = {{16{1'b0}}, ts_i_store_data[15 : 0]};
            end
            default : begin
                ts_o_store_mask = {4{1'b0}};
                ts_o_store_data = {`DWIDTH{1'b0}};
            end 
        endcase
    end
endmodule
`endif 