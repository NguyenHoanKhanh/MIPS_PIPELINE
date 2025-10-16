`ifndef FORWARDING_V
`define FORWARDING_V
`include "./source/header.vh"
module forwarding (
    ds_es_i_addr_rs1, ds_es_i_addr_rs2, es_ms_i_alu_value, es_ms_i_regwrite, 
    ms_wb_i_regwrite, ms_wb_i_load_addr, f_o_control_rs1, 
    f_o_control_rs2
);
    input [`AWIDTH - 1 : 0] ds_es_i_addr_rs1, ds_es_i_addr_rs2;
    input [`AWIDTH - 1 : 0] es_ms_i_alu_value;
    input es_ms_i_regwrite;
    input [`AWIDTH - 1 : 0] ms_wb_i_load_addr;
    input ms_wb_i_regwrite;
    output reg [1 : 0] f_o_control_rs1, f_o_control_rs2;

    always @(*) begin
        f_o_control_rs1 = 2'd0;
        f_o_control_rs2 = 2'd0;

        if ((ds_es_i_addr_rs1 == es_ms_i_alu_value) && es_ms_i_regwrite) begin
            f_o_control_rs1 = 2'd1;
        end 
        else if ((ds_es_i_addr_rs1 == ms_wb_i_load_addr) && ms_wb_i_regwrite) begin
            f_o_control_rs1 = 2'd2;
        end
        else begin
            f_o_control_rs1 = 2'd0;
        end

        if ((ds_es_i_addr_rs2 == es_ms_i_alu_value) && es_ms_i_regwrite) begin
            f_o_control_rs2 = 2'd1;
        end 
        else if ((ds_es_i_addr_rs2 == ms_wb_i_load_addr) && ms_wb_i_regwrite) begin
            f_o_control_rs2 = 2'd2;
        end
        else begin
            f_o_control_rs2 = 2'd0;
        end
    end
endmodule
`endif 