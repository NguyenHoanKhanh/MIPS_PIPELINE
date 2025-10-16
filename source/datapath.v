`ifndef DATAPATH_V
`define DATAPATH_V
`include "./source/program_counter.v"
`include "./source/imem.v"
`include "./source/instruction_fetch.v"
`include "./source/decoder_stage.v"
`include "./source/execute_stage.v"
`include "./source/memory.v"
`include "./source/forwarding.v"
`include "./source/mux3_1.v"
`include "./source/mux2_1.v"

module datapath (
    d_clk, d_rst, d_i_ce, fs_ds_o_pc, write_back_data
);
    input d_clk, d_rst;
    input d_i_ce;
    output reg [`PC_WIDTH - 1 : 0] fs_ds_o_pc;
    output [`DWIDTH - 1 : 0] write_back_data;

    wire [`PC_WIDTH - 1 : 0] pc_im_o_pc;
    wire pc_is_o_ce;
    prog_counter p_c (
        .pc_clk(d_clk), 
        .pc_rst(d_rst), 
        .pc_i_ce(d_i_ce), 
        .pc_i_change_pc(es_pc_o_change_pc), 
        .pc_i_pc(es_pc_o_alu_pc), 
        .pc_o_pc(pc_im_o_pc), 
        .pc_o_ce(pc_is_o_ce)
    );

    reg im_ds_o_ce;
    wire im_o_ce;
    reg [`IWIDTH - 1 : 0] im_ds_o_instr;
    wire [`IWIDTH - 1 : 0] im_o_instr;
    imem i_m (
        .im_clk(d_clk), 
        .im_rst(d_rst), 
        .im_i_ce(pc_is_o_ce), 
        .im_i_address(pc_im_o_pc), 
        .im_o_instr(im_o_instr), 
        .im_o_ce(im_o_ce)
    );
    
    always @(posedge d_clk, negedge d_rst) begin
        if (!d_rst) begin
            im_ds_o_ce <= 1'b0;
            im_ds_o_instr <= {`IWIDTH{1'b0}};
            fs_ds_o_pc <= {`PC_WIDTH{1'b0}};
        end
        else begin
            fs_ds_o_pc <= pc_im_o_pc;
            im_ds_o_ce <= im_o_ce;
            im_ds_o_instr <= im_o_instr;
        end
    end

    reg ds_es_o_ce;
    reg ds_es_o_branch;
    reg ds_es_o_alu_src;
    reg ds_es_o_memtoreg;
    reg [`PC_WIDTH - 1 : 0] ds_es_o_pc;
    reg [`IMM_WIDTH - 1 : 0] ds_es_o_imm;
    reg ds_es_o_memread, ds_es_o_memwrite;
    reg [`FUNCT_WIDTH - 1 : 0] ds_es_o_funct;
    reg [`OPCODE_WIDTH - 1 : 0] ds_es_o_opcode;
    reg [`DWIDTH - 1 : 0] ds_mx_o_data_rs, ds_mx_o_data_rt;
    reg [`AWIDTH - 1 : 0] ds_es_o_addr_rs, ds_es_o_addr_rt;
    reg [`AWIDTH - 1 : 0] ds_mx_o_addr_rd;
    reg ds_es_o_reg_wr;
    wire ds_o_ce;
    wire ds_o_branch;
    wire ds_o_alu_src;
    wire ds_o_memtoreg;
    wire ds_o_memread, ds_o_memwrite;
    wire [`IMM_WIDTH - 1 : 0] ds_o_imm;
    wire [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    wire [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    wire [`DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    wire [`AWIDTH - 1 : 0] ds_o_addr_rs, ds_o_addr_rt;
    wire [`AWIDTH - 1 : 0] ds_i_addr_rd;
    wire ds_o_reg_wr;
    decoder_stage ds (
        .ds_clk(d_clk), 
        .ds_rst(d_rst), 
        .ds_i_ce(im_ds_o_ce), 
        .ds_i_data_rd(write_back_data), 
        .ds_i_instr(im_ds_o_instr), 
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
        .ds_o_memtoreg(ds_o_memtoreg),
        .ds_o_addr_rs(ds_o_addr_rs), 
        .ds_o_addr_rt(ds_o_addr_rt),
        .ds_i_addr_rd(ds_i_addr_rd),
        .ds_o_reg_wr(ds_o_reg_wr)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            ds_es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            ds_es_o_funct <= {`FUNCT_WIDTH{1'b0}};
            ds_mx_o_data_rs <= {`DWIDTH{1'b0}};
            ds_mx_o_data_rt <= {`DWIDTH{1'b0}};
            ds_es_o_imm <= {`IMM_WIDTH{1'b0}};
            ds_es_o_ce <= 1'b0;
            ds_es_o_branch <= 1'b0;
            ds_es_o_alu_src <= 1'b0;
            ds_es_o_memread <= 1'b0;
            ds_es_o_memwrite <= 1'b0;
            ds_es_o_memtoreg <= 1'b0;
            ds_es_o_pc <= {`PC_WIDTH{1'b0}};
            ds_mx_o_addr_rd <= {`AWIDTH{1'b0}};
            ds_es_o_reg_wr <= 1'b0;
            ds_es_o_addr_rs <= {`AWIDTH{1'b0}};
            ds_es_o_addr_rt <= {`AWIDTH{1'b0}};
        end
        else begin
            if (!f_o_stall) begin
                ds_es_o_ce <= ds_o_ce;
                ds_es_o_opcode <= ds_o_opcode;
                ds_es_o_funct <= ds_o_funct;
                ds_mx_o_data_rs <= ds_o_data_rs;
                ds_mx_o_data_rt <= ds_o_data_rt;
                ds_es_o_imm <= ds_o_imm;
                ds_es_o_branch <= ds_o_branch;
                ds_es_o_alu_src <= ds_o_alu_src;
                ds_es_o_memread <= ds_o_memread;
                ds_es_o_memwrite <= ds_o_memwrite;
                ds_es_o_memtoreg <= ds_o_memtoreg;
                ds_es_o_pc <= fs_ds_o_pc;
                ds_mx_o_addr_rd <= ds_i_addr_rd;
                ds_es_o_reg_wr <= ds_o_reg_wr;
                ds_es_o_addr_rs <= ds_o_addr_rs;
                ds_es_o_addr_rt <= ds_o_addr_rt;
            end
            else begin
                ds_es_o_ce <= 1'b0;
                ds_es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
                ds_es_o_funct <= {`FUNCT_WIDTH{1'b0}};
                ds_mx_o_data_rs <= {`DWIDTH{1'b0}};
                ds_mx_o_data_rt <= {`DWIDTH{1'b0}};
                ds_es_o_imm <= {`IMM_WIDTH{1'b0}};
                ds_es_o_branch <= 1'b0;
                ds_es_o_alu_src <= 1'b0;
                ds_es_o_memread <= 1'b0;
                ds_es_o_memwrite <= 1'b0;
                ds_es_o_memtoreg <= 1'b0;
                ds_es_o_pc <= {`PC_WIDTH{1'b0}};
                ds_mx_o_addr_rd <= {`AWIDTH{1'b0}};
                ds_es_o_reg_wr <= 1'b0;
                ds_es_o_addr_rs <= {`AWIDTH{1'b0}};
                ds_es_o_addr_rt <= {`AWIDTH{1'b0}};
            end
        end
    end

    wire [`DWIDTH - 1 : 0] mx_es_o_data_rs1;
    mux31 m1 (
        .a(ds_mx_o_data_rs), 
        .b(es_ms_alu_value), 
        .c(write_back_data), 
        .sel(forward_rs1), 
        .data_out(mx_es_o_data_rs1)
    );  

    wire [`DWIDTH - 1 : 0] mx_es_o_data_rs2;
    mux31 m2 (
        .a(ds_mx_o_data_rt),
        .b(es_ms_alu_value), 
        .c(write_back_data), 
        .sel(forward_rs2), 
        .data_out(mx_es_o_data_rs2)
    );

    wire [`AWIDTH - 1 : 0] mx_es_o_addr_rd;
    mux21 m3 (
        .a(ds_es_o_addr_rt), 
        .b(ds_mx_o_addr_rd), 
        .opcode(ds_es_o_opcode), 
        .out(mx_es_o_addr_rd)
    );

    reg es_ms_o_ce;
    reg es_ms_o_zero;
    reg es_pc_o_change_pc;
    reg [`DWIDTH - 1 : 0] es_ms_alu_value;
    reg [`PC_WIDTH - 1 : 0] es_pc_o_alu_pc;
    reg [`DWIDTH - 1 : 0] es_ms_o_data_rt;
    reg es_ms_o_memread, es_ms_o_memwrite;
    reg es_ms_o_memtoreg;
    reg [`AWIDTH - 1 : 0] es_ms_o_addr_rd;
    reg es_ms_o_regwr;
    wire es_o_ce;
    wire es_o_zero;
    wire es_o_change_pc;
    wire [`PC_WIDTH - 1 : 0] es_o_alu_pc;
    wire [`DWIDTH - 1 : 0] es_o_alu_value;

    execute es (
        .es_i_ce(ds_es_o_ce), 
        .es_i_alu_src(ds_es_o_alu_src), 
        .es_i_branch(ds_es_o_branch),
        .es_i_pc(ds_es_o_pc),
        .es_i_imm(ds_es_o_imm), 
        .es_i_alu_op(ds_es_o_opcode), 
        .es_i_alu_funct(ds_es_o_funct),
        .es_i_data_rs(mx_es_o_data_rs1), 
        .es_i_data_rt(mx_es_o_data_rs2), 
        .es_o_alu_value(es_o_alu_value), 
        .es_o_alu_pc(es_o_alu_pc),
        .es_o_zero(es_o_zero),
        .es_o_ce(es_o_ce),
        .es_o_change_pc(es_o_change_pc)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            es_ms_alu_value <= {`DWIDTH{1'b0}};
            es_pc_o_alu_pc <= {`PC_WIDTH{1'b0}};
            es_ms_o_zero <= 1'b0;
            es_ms_o_ce <= 1'b0;
            es_pc_o_change_pc <= 1'b0;
            es_ms_o_data_rt <= {`DWIDTH{1'b0}};
            es_ms_o_memread <= 1'b0;
            es_ms_o_memwrite <= 1'b0;
            es_ms_o_memtoreg <= 1'b0;
            es_ms_o_addr_rd <= {`AWIDTH{1'b0}};
            es_ms_o_regwr <= 1'b0;
        end
        else begin
            es_ms_alu_value <= es_o_alu_value;
            es_pc_o_alu_pc <= es_o_alu_pc;
            es_ms_o_zero <= es_o_zero;
            es_ms_o_ce <= es_o_ce;
            es_pc_o_change_pc <= es_o_change_pc;
            es_ms_o_data_rt <= mx_es_o_data_rs2;
            es_ms_o_memread <= ds_es_o_memread;
            es_ms_o_memwrite <= ds_es_o_memwrite;
            es_ms_o_memtoreg <= ds_es_o_memtoreg;
            es_ms_o_addr_rd <= mx_es_o_addr_rd;
            es_ms_o_regwr <= ds_es_o_reg_wr;
        end
    end
    
    reg ms_wb_o_memtoreg;
    reg ms_wb_o_regwr;
    reg [`AWIDTH - 1 : 0] ms_wb_o_addr_rd;
    reg [`DWIDTH - 1 : 0] ms_wb_o_load_data;
    reg [`DWIDTH - 1 : 0] ms_wb_o_alu_value;
    wire [`DWIDTH - 1 : 0] ms_o_load_data;
    memory m (
        .m_clk(d_clk), 
        .m_rst(d_rst), 
        .m_wr_en(es_ms_o_memwrite), 
        .m_rd_en(es_ms_o_memread), 
        .m_i_ce(es_ms_o_ce), 
        .alu_value_addr(es_ms_alu_value),
        .m_i_store_data(es_ms_o_data_rt), 
        .m_o_load_data(ms_o_load_data)
    );

    always @(posedge d_clk, negedge d_rst) begin
        if (!d_rst) begin
            ms_wb_o_memtoreg <= 1'b0;
            ms_wb_o_load_data <= {`DWIDTH{1'b0}};
            ms_wb_o_alu_value <= {`DWIDTH{1'b0}};
            ms_wb_o_addr_rd <= {`AWIDTH{1'b0}};
            ms_wb_o_regwr <= 1'b0;
        end
        else begin
            ms_wb_o_memtoreg <= es_ms_o_memtoreg;
            ms_wb_o_load_data <= ms_o_load_data;
            ms_wb_o_alu_value <= es_ms_alu_value;
            ms_wb_o_addr_rd <= es_ms_o_addr_rd;
            ms_wb_o_regwr <= es_ms_o_regwr;
        end
    end

    wire [1 : 0] forward_rs1, forward_rs2;
    wire f_o_stall;
    forwarding f (
        .ds_es_i_opcode(ds_es_o_opcode),
        .ds_es_i_addr_rs1(ds_es_o_addr_rs), 
        .ds_es_i_addr_rs2(ds_es_o_addr_rt), 
        .es_ms_i_addr_rd(es_ms_o_addr_rd), 
        .es_ms_i_regwrite(es_ms_o_regwr), 
        .ms_wb_i_regwr(ms_wb_o_regwr), 
        .ms_wb_i_addr_rd(ms_wb_o_addr_rd), 
        .f_o_control_rs1(forward_rs1), 
        .f_o_control_rs2(forward_rs2),
        .f_o_stall(f_o_stall)
    );

    assign write_back_data = (ms_wb_o_memtoreg) ? ms_wb_o_load_data : ms_wb_o_alu_value;
endmodule
`endif  