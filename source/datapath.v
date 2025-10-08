`ifndef DATAPATH_V
`define DATAPATH_V
`include "./source/instruction_fetch.v"
`include "./source/decoder_stage.v"
`include "./source/execute_stage.v"
`include "./source/memory.v"

module datapath #(
    parameter DWIDTH = 32,
    parameter IWIDTH = 32,
    parameter AWIDTH = 5,
    parameter PC_WIDTH = 32,
    parameter DEPTH = 6,
    parameter AWIDTH_MEM = 32,
    parameter IMM_WIDTH = 16
) (
    d_clk, d_rst, d_i_ce, fs_ds_o_pc, write_back_data, ds_es_o_opcode
);
    input d_clk, d_rst;
    input d_i_ce;
    output reg [`OPCODE_WIDTH - 1 : 0] ds_es_o_opcode;
    output reg [PC_WIDTH - 1 : 0] fs_ds_o_pc;
    output [DWIDTH - 1 : 0] write_back_data;

    reg fs_ds_o_ce;
    reg [IWIDTH - 1 : 0] fs_ds_o_instr;
    wire fs_o_ce;
    wire [PC_WIDTH - 1 : 0] fs_o_pc;
    wire [IWIDTH - 1 : 0] fs_o_instr;
    instruction_fetch #(
        .PC_WIDTH(PC_WIDTH),
        .IWIDTH(IWIDTH),
        .DEPTH(DEPTH)
    ) is (
        .f_clk(d_clk), 
        .f_rst(d_rst), 
        .f_i_ce(d_i_ce), 
        .f_i_pc(es_ms_o_alu_pc),
        .f_i_change_pc(es_is_change_pc),
        .f_o_pc(fs_o_pc), 
        .f_o_ce(fs_o_ce),
        .f_o_instr(fs_o_instr)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            fs_ds_o_instr <= {IWIDTH{1'b0}};
            fs_ds_o_ce <= 1'b0;
            fs_ds_o_pc <= {PC_WIDTH{1'b0}};
        end
        else begin
            fs_ds_o_instr <= fs_o_instr;
            fs_ds_o_ce <= fs_o_ce;
            fs_ds_o_pc <= fs_o_pc;
        end
    end

    reg ds_es_o_ce;
    reg ds_es_o_branch;
    reg ds_es_o_alu_src;
    reg ds_wb_o_memtoreg;
    reg [PC_WIDTH - 1 : 0] ds_ms_o_pc;
    reg [IMM_WIDTH - 1 : 0] ds_es_o_imm;
    reg ds_ms_o_memread, ds_ms_o_memwrite;
    reg [`FUNCT_WIDTH - 1 : 0] ds_es_o_funct;
    reg [DWIDTH - 1 : 0] ds_es_o_data_rs, ds_es_o_data_rt;
    wire ds_o_ce;
    wire ds_o_branch;
    wire ds_o_alu_src;
    wire ds_o_memtoreg;
    wire ds_o_memread, ds_o_memwrite;
    wire [IMM_WIDTH - 1 : 0] ds_o_imm;
    wire [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    wire [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    wire [DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    decoder_stage #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .IWIDTH(IWIDTH)
    ) ds (
        .ds_clk(d_clk), 
        .ds_rst(d_rst), 
        .ds_i_ce(fs_ds_o_ce), 
        .ds_i_data_rd(write_back_data), 
        .ds_i_instr(fs_ds_o_instr), 
        .ds_o_opcode(ds_o_opcode), 
        .ds_o_funct(ds_o_funct), 
        .ds_o_data_rs(ds_o_data_rs), 
        .ds_o_data_rt(ds_o_data_rt), 
        .ds_o_imm(ds_o_imm),
        .ds_o_ce(ds_o_ce),
        .ds_o_branch(ds_o_branch),
        .ds_o_alu_src(ds_o_alu_src),
        .ds_o_memread(ds_o_memread),
        .ds_o_memwrite(ds_o_memwrite),
        .ds_o_memtoreg(ds_o_memtoreg)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            ds_es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            ds_es_o_funct <= {`FUNCT_WIDTH{1'b0}};
            ds_es_o_data_rs <= {DWIDTH{1'b0}};
            ds_es_o_data_rt <= {DWIDTH{1'b0}};
            ds_es_o_imm <= {IMM_WIDTH{1'b0}};
            ds_es_o_ce <= 1'b0;
            ds_es_o_branch <= 1'b0;
            ds_es_o_alu_src <= 1'b0;
            ds_ms_o_memread <= 1'b0;
            ds_ms_o_memwrite <= 1'b0;
            ds_wb_o_memtoreg <= 1'b0;
            ds_ms_o_pc <= {PC_WIDTH{1'b0}};
        end
        else begin
            ds_es_o_opcode <= ds_o_opcode;
            ds_es_o_funct <= ds_o_funct;
            ds_es_o_data_rs <= ds_o_data_rs;
            ds_es_o_data_rt <= ds_o_data_rt;
            ds_es_o_imm <= ds_o_imm;
            ds_es_o_ce <= ds_o_ce;
            ds_es_o_branch <= ds_o_branch;
            ds_es_o_alu_src <= ds_o_alu_src;
            ds_ms_o_memread <= ds_o_memread;
            ds_ms_o_memwrite <= ds_o_memwrite;
            ds_wb_o_memtoreg <= ds_o_memtoreg;
            ds_ms_o_pc <= fs_ds_o_pc;
        end
    end

    reg es_ms_o_ce;
    reg es_ms_o_zero;
    reg es_is_change_pc;
    reg [DWIDTH - 1 : 0] es_ms_alu_value;
    reg [PC_WIDTH - 1 : 0] es_ms_o_alu_pc;
    reg [`FUNCT_WIDTH - 1 : 0] es_ms_o_funct;
    reg [`OPCODE_WIDTH - 1 : 0] es_ms_o_opcode;
    wire es_o_ce;
    wire es_o_zero;
    wire es_change_pc;
    wire [PC_WIDTH - 1 : 0] es_o_alu_pc;
    wire [DWIDTH - 1 : 0] es_o_alu_value;
    wire [`FUNCT_WIDTH - 1 : 0] es_o_funct;
    wire [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    execute #(
        .DWIDTH(DWIDTH)
    ) es (
        .es_clk(d_clk), 
        .es_rst(d_rst), 
        .es_i_ce(ds_es_o_ce), 
        .es_i_alu_src(ds_es_o_alu_src), 
        .es_i_branch(ds_es_o_branch),
        .es_i_pc(ds_ms_o_pc),
        .es_i_imm(ds_es_o_imm), 
        .es_i_alu_op(ds_es_o_opcode), 
        .es_i_alu_funct(ds_es_o_funct),
        .es_i_data_rs(ds_es_o_data_rs), 
        .es_i_data_rt(ds_es_o_data_rt), 
        .es_o_alu_value(es_o_alu_value), 
        .es_o_alu_pc(es_o_alu_pc),
        .es_o_opcode(es_o_opcode), 
        .es_o_funct(es_o_funct), 
        .es_o_zero(es_o_zero),
        .es_o_ce(es_o_ce),
        .es_o_change_pc(es_o_change_pc)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            es_ms_alu_value <= {DWIDTH{1'b0}};
            es_ms_o_alu_pc <= {PC_WIDTH{1'b0}};
            es_ms_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            es_ms_o_funct <= {`FUNCT_WIDTH{1'b0}};
            es_ms_o_zero <= 1'b0;
            es_ms_o_ce <= 1'b0;
            es_is_change_pc <= 1'b0;
        end
        else begin
            es_ms_alu_value <= es_o_alu_value;
            es_ms_o_alu_pc <= es_o_alu_pc;
            es_ms_o_opcode <= es_o_opcode;
            es_ms_o_funct <= es_o_funct;
            es_ms_o_zero <= es_o_zero;
            es_ms_o_ce <= es_o_ce;
            es_is_change_pc <= es_o_change_pc;
        end
    end

    reg [DWIDTH - 1 : 0] ms_wb_load_data;
    wire [DWIDTH - 1 : 0] ms_o_load_data;
    memory #(
        .DWIDTH(DWIDTH),
        .AWIDTH_MEM(AWIDTH_MEM)
    ) m (
        .m_clk(d_clk), 
        .m_rst(d_rst), 
        .m_wr_en(ds_ms_o_memwrite), 
        .m_rd_en(ds_ms_o_memread), 
        .m_i_ce(es_ms_o_ce), 
        .alu_value_addr(es_ms_alu_value),
        .m_i_store_data(ds_es_o_data_rt), 
        .m_o_load_data(ms_o_load_data)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            ms_wb_load_data <= {DWIDTH{1'b0}};
        end
        else begin
            ms_wb_load_data <= ms_o_load_data;
        end
    end

    assign write_back_data = (ds_wb_o_memtoreg) ? ms_wb_load_data : es_ms_alu_value;
endmodule
`endif 