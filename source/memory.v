`ifndef MEMORY_V
`define MEMORY_V
`include "./source/header.vh"
module memory (
    m_clk, m_rst, m_wr_en, m_i_ce, m_i_store_data, 
    alu_value_addr, m_o_load_data, m_i_mask
);
    input m_i_ce;
    input m_wr_en;  
    input m_clk, m_rst;
    input [3 : 0] m_i_mask;
    input [`DWIDTH - 1 : 0] m_i_store_data;
    output [`DWIDTH - 1 : 0] m_o_load_data;
    input [`AWIDTH_MEM - 1 : 0] alu_value_addr;
    integer i;
    reg [`DWIDTH - 1 : 0] data_mem [0 : `AWIDTH_MEM - 1];

    always @(negedge m_clk, negedge m_rst) begin
        if (!m_rst) begin
            for (i = 0; i < `AWIDTH_MEM; i = i + 1) begin
                data_mem[i] <= i;   
            end
        end
        else begin
            if (m_i_ce) begin
                if (m_wr_en) begin
                    if (m_i_mask[0]) begin
                        data_mem[alu_value_addr][7 : 0] <= m_i_store_data[7 : 0];
                    end
                    if (m_i_mask[1]) begin
                        data_mem[alu_value_addr][15 : 8] <= m_i_store_data[15 : 8];
                    end
                    if (m_i_mask[2]) begin
                        data_mem[alu_value_addr][23 : 16] <= m_i_store_data[23 : 16];
                    end
                    if (m_i_mask[3]) begin
                        data_mem[alu_value_addr][31 : 24] <= m_i_store_data[31 : 24];
                    end
                end
            end
        end
    end
    assign m_o_load_data = data_mem[alu_value_addr];
endmodule
`endif 