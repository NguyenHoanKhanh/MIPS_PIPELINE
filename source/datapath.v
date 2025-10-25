`ifndef DATAPATH_V
`define DATAPATH_V
`include "./source/program_counter.v"
`include "./source/imem.v"
`include "./source/decoder_stage.v"
`include "./source/execute_stage.v"
`include "./source/memory.v"
`include "./source/forwarding.v"
`include "./source/mux3_1.v"
`include "./source/mux2_1.v"
`include "./source/treat_load.v"
`include "./source/treat_store.v"
`include "./source/adder.v"

module datapath (
    d_clk, d_rst, d_i_ce, im_ds_o_pc, write_back_data
);
    input d_clk, d_rst;
    input d_i_ce;
    output [`DWIDTH - 1 : 0] write_back_data;
    output reg [`PC_WIDTH - 1 : 0] im_ds_o_pc;

    reg pc_im_o_ce;
    reg [`PC_WIDTH - 1 : 0] pc_im_o_pc;
    wire pc_o_ce;
    wire [`PC_WIDTH - 1 : 0] pc_o_pc;
    prog_counter p_c (
        .pc_clk(d_clk), 
        .pc_rst(d_rst), 
        .pc_i_ce(d_i_ce), 
        .pc_i_change_pc(a_o_change_pc), 
        .pc_i_pc(a_o_pc), 
        .pc_o_pc(pc_o_pc), 
        .pc_o_ce(pc_o_ce)
    );

    always @(posedge d_clk, negedge d_rst) begin
        if (!d_rst) begin
            pc_im_o_ce <= 1'b0;
            pc_im_o_pc <= {`PC_WIDTH{1'b0}};
        end
        else begin
            pc_im_o_ce <= pc_o_ce;
            pc_im_o_pc <= pc_o_pc;
        end
    end

    reg im_ds_o_ce;
    wire im_o_ce;
    wire [`IWIDTH - 1 : 0] im_o_instr;
    reg [`IWIDTH - 1 : 0] im_ds_o_instr;
    imem i_m (
        .im_clk(d_clk), 
        .im_rst(d_rst), 
        .im_i_ce(pc_im_o_ce), 
        .im_i_address(pc_im_o_pc), 
        .im_o_ce(im_o_ce),
        .im_o_instr(im_o_instr) 
    );
    
    always @(posedge d_clk, negedge d_rst) begin
        if (!d_rst) begin
            im_ds_o_ce <= 1'b0;
            im_ds_o_pc <= {`PC_WIDTH{1'b0}};
            im_ds_o_instr <= {`IWIDTH{1'b0}};
        end
        else begin
            if (f_o_stall) begin
                im_ds_o_ce <= im_ds_o_ce;
                im_ds_o_pc <= im_ds_o_pc;
                im_ds_o_instr <= im_ds_o_instr; 
            end
            else begin
                im_ds_o_ce <= im_o_ce;
                im_ds_o_pc <= pc_im_o_pc;
                im_ds_o_instr <= im_o_instr;
            end
        end
    end

    reg ds_es_o_ce;
    reg ds_es_o_reg_wr;
    reg ds_es_o_alu_src;
    reg [`PC_WIDTH - 1 : 0] ds_es_o_pc;
    reg [`IMM_WIDTH - 1 : 0] ds_es_o_imm;
    reg [`AWIDTH - 1 : 0] ds_mx_o_addr_rd;
    reg [`FUNCT_WIDTH - 1 : 0] ds_es_o_funct;
    reg [`OPCODE_WIDTH - 1 : 0] ds_es_o_opcode;
    reg [`AWIDTH - 1 : 0] ds_f_o_addr_rs, ds_es_o_addr_rt;
    reg [`DWIDTH - 1 : 0] ds_mx_o_data_rs, ds_mx_o_data_rt;
    reg ds_es_o_branch;
    reg ds_es_o_memtoreg;
    // reg ds_es_o_memread; 
    reg ds_es_o_memwrite;
    reg ds_es_o_jal;
    reg [`JUMP_WIDTH - 1 : 0] ds_es_o_jal_addr;
    reg ds_es_o_jr;
    wire ds_o_ce;
    wire ds_o_reg_wr;
    wire ds_o_alu_src;
    wire [`IMM_WIDTH - 1 : 0] ds_o_imm;
    wire [`AWIDTH - 1 : 0] ds_o_addr_rd;
    wire [`FUNCT_WIDTH - 1 : 0] ds_o_funct;
    wire [`OPCODE_WIDTH - 1 : 0] ds_o_opcode;
    wire [`DWIDTH - 1 : 0] ds_o_data_rs, ds_o_data_rt;
    wire [`AWIDTH - 1 : 0] ds_o_addr_rs, ds_o_addr_rt;
    wire ds_o_branch;
    wire ds_o_memtoreg;
    wire ds_o_memwrite;
    // wire ds_o_memread; 
    wire ds_o_jal;
    wire [`JUMP_WIDTH - 1 : 0] ds_o_jal_addr;
    wire ds_o_change_pc;
    wire [`PC_WIDTH - 1 : 0] ds_o_alu_pc;
    wire ds_o_jr;
    decoder_stage ds (
        .ds_clk(d_clk), 
        .ds_rst(d_rst), 
        .ds_i_ce(im_ds_o_ce), 
        .ds_i_instr(im_ds_o_instr), 
        .ds_i_data_rd(write_back_data), 
        .ds_i_addr_rd(ms_wb_o_addr_rd),
        .ds_i_reg_wr(ms_wb_o_regwr),
        .ds_o_ce(ds_o_ce),
        .ds_o_imm(ds_o_imm),
        .ds_o_funct(ds_o_funct), 
        .ds_o_reg_wr(ds_o_reg_wr),
        .ds_o_opcode(ds_o_opcode), 
        .ds_o_data_rs(ds_o_data_rs), 
        .ds_o_data_rt(ds_o_data_rt), 
        .ds_o_alu_src(ds_o_alu_src),
        .ds_o_addr_rs(ds_o_addr_rs), 
        .ds_o_addr_rt(ds_o_addr_rt),
        .ds_o_addr_rd(ds_o_addr_rd),
        .ds_o_branch(ds_o_branch),
        .ds_o_memwrite(ds_o_memwrite),
        .ds_o_memtoreg(ds_o_memtoreg),
        .ds_o_jal(ds_o_jal),
        .ds_o_jal_addr(ds_o_jal_addr),
        .ds_o_jr(ds_o_jr)
    );

    wire [`PC_WIDTH - 1 : 0] a_o_pc;
    wire a_o_change_pc;
    adder a (
        .i_pc(im_ds_o_pc), 
        .i_imm(ds_o_imm), 
        .i_branch(ds_o_branch), 
        .i_opcode(ds_o_opcode), 
        .i_es_opcode(ds_es_o_opcode), 
        .i_es_o_pc(es_pc_o_alu_pc), 
        .i_es_o_change_pc(es_pc_o_change_pc),  
        .i_data_r1(ds_o_data_rs), 
        .i_data_r2(ds_o_data_rt), 
        .o_pc(a_o_pc), 
        .o_compare(a_o_change_pc)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            ds_es_o_ce <= 1'b0;
            ds_es_o_jr <= 1'b0; 
            ds_es_o_jal <= 1'b0;
            ds_es_o_reg_wr <= 1'b0;
            ds_es_o_alu_src <= 1'b0;
            ds_es_o_memwrite <= 1'b0;
            ds_es_o_memtoreg <= 1'b0;
            ds_es_o_branch <= 1'b0;
            // ds_es_o_memread <= 1'b0;
            ds_es_o_pc <= {`PC_WIDTH{1'b0}};
            ds_es_o_imm <= {`IMM_WIDTH{1'b0}};
            ds_f_o_addr_rs <= {`AWIDTH{1'b0}};
            ds_mx_o_addr_rd <= {`AWIDTH{1'b0}};
            ds_mx_o_data_rs <= {`DWIDTH{1'b0}};
            ds_mx_o_data_rt <= {`DWIDTH{1'b0}};
            ds_es_o_addr_rt <= {`AWIDTH{1'b0}};
            ds_es_o_funct <= {`FUNCT_WIDTH{1'b0}};
            ds_es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
            ds_es_o_jal_addr <= {`JUMP_WIDTH{1'b0}};
        end
        else begin
            if (!f_o_stall) begin
                ds_es_o_ce <= ds_o_ce;
                ds_es_o_jr <= ds_o_jr;
                ds_es_o_jal <= ds_o_jal;
                ds_es_o_imm <= ds_o_imm;
                ds_es_o_pc <= im_ds_o_pc;
                ds_es_o_funct <= ds_o_funct;
                ds_es_o_reg_wr <= ds_o_reg_wr;
                ds_es_o_opcode <= ds_o_opcode;
                ds_es_o_branch <= ds_o_branch;
                ds_f_o_addr_rs <= ds_o_addr_rs;
                ds_mx_o_data_rt <= ds_o_data_rt;
                ds_mx_o_data_rs <= ds_o_data_rs;
                ds_es_o_alu_src <= ds_o_alu_src;
                // ds_es_o_memread <= ds_o_memread;
                ds_mx_o_addr_rd <= ds_o_addr_rd;
                ds_es_o_addr_rt <= ds_o_addr_rt;
                ds_es_o_memwrite <= ds_o_memwrite;
                ds_es_o_memtoreg <= ds_o_memtoreg;
                ds_es_o_jal_addr <= ds_o_jal_addr;
            end
            else begin
                ds_es_o_ce <= 1'b0;
                ds_es_o_jr <= 1'b0;
                ds_es_o_jal <= 1'b0;
                ds_es_o_reg_wr <= 1'b0;
                ds_es_o_alu_src <= 1'b0;
                ds_es_o_memwrite <= 1'b0;
                ds_es_o_memtoreg <= 1'b0;
                ds_es_o_branch <= 1'b0;
                // ds_es_o_memread <= 1'b0;
                ds_es_o_pc <= {`PC_WIDTH{1'b0}};
                ds_es_o_imm <= {`IMM_WIDTH{1'b0}};
                ds_f_o_addr_rs <= {`AWIDTH{1'b0}};
                ds_mx_o_addr_rd <= {`AWIDTH{1'b0}};
                ds_mx_o_data_rs <= {`DWIDTH{1'b0}};
                ds_mx_o_data_rt <= {`DWIDTH{1'b0}};
                ds_es_o_addr_rt <= {`AWIDTH{1'b0}};
                ds_es_o_funct <= {`FUNCT_WIDTH{1'b0}};
                ds_es_o_opcode <= {`OPCODE_WIDTH{1'b0}};
                ds_es_o_jal_addr <= {`JUMP_WIDTH{1'b0}};
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
    mux2_1 m3 (
        .a(ds_es_o_addr_rt), 
        .b(ds_mx_o_addr_rd), 
        .opcode(ds_es_o_opcode), 
        .out(mx_es_o_addr_rd)
    );

    reg es_ms_o_ce;
    reg es_ms_o_regwr;
    reg es_ms_o_memwrite;
    reg es_ms_o_memtoreg;
    reg es_pc_o_change_pc;
    // reg es_ms_o_memread;
    reg [`DWIDTH - 1 : 0] es_ms_alu_value;
    reg [`DWIDTH - 1 : 0] es_ms_o_data_rt;
    reg [`AWIDTH - 1 : 0] es_ms_o_addr_rd;
    reg [`PC_WIDTH - 1 : 0] es_pc_o_alu_pc;
    reg [`OPCODE_WIDTH - 1 : 0] es_ms_o_opcode;
    wire es_o_ce;
    wire es_o_change_pc;
    wire [`PC_WIDTH - 1 : 0] es_o_alu_pc;
    wire [`DWIDTH - 1 : 0] es_o_alu_value;
    wire [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    execute es (
        .es_i_ce(ds_es_o_ce), 
        .es_i_pc(ds_es_o_pc),
        .es_i_jr(ds_es_o_jr),
        .es_i_imm(ds_es_o_imm), 
        .es_i_jal(ds_es_o_jal),
        .es_i_alu_op(ds_es_o_opcode), 
        .es_i_alu_src(ds_es_o_alu_src), 
        .es_i_alu_funct(ds_es_o_funct),
        .es_i_data_rs(mx_es_o_data_rs1), 
        .es_i_data_rt(mx_es_o_data_rs2), 
        .es_i_jal_addr(ds_es_o_jal_addr),
        .es_o_ce(es_o_ce),
        .es_o_alu_pc(es_o_alu_pc),
        .es_o_opcode(es_o_opcode),
        .es_o_alu_value(es_o_alu_value), 
        .es_o_change_pc(es_o_change_pc)
    );

    wire [3 : 0] ts_o_store_mask;
    wire [`DWIDTH - 1 : 0] ts_o_store_data;
    reg [3 : 0] ts_ms_o_store_mask;
    treatstore ts (
        .ts_i_opcode(ds_es_o_opcode), 
        .ts_i_store_data(mx_es_o_data_rs2), 
        .ts_o_store_data(ts_o_store_data), 
        .ts_o_store_mask(ts_o_store_mask)
    );

    always @(posedge d_clk or negedge d_rst) begin
        if (!d_rst) begin
            es_ms_alu_value <= {`DWIDTH{1'b0}};
            es_pc_o_alu_pc <= {`PC_WIDTH{1'b0}};
            es_ms_o_ce <= 1'b0;
            es_pc_o_change_pc <= 1'b0;
            es_ms_o_data_rt <= {`DWIDTH{1'b0}};
            // es_ms_o_memread <= 1'b0;
            es_ms_o_memwrite <= 1'b0;
            es_ms_o_memtoreg <= 1'b0;
            es_ms_o_addr_rd <= {`AWIDTH{1'b0}};
            es_ms_o_regwr <= 1'b0;
            ts_ms_o_store_mask <= 4'b0;
            es_ms_o_opcode <= {`OPCODE_WIDTH{1'b0}};
        end
        else begin
            es_ms_o_ce <= es_o_ce;
            es_ms_o_opcode <= es_o_opcode;
            es_pc_o_alu_pc <= es_o_alu_pc;
            es_ms_o_regwr <= ds_es_o_reg_wr;
            es_ms_alu_value <= es_o_alu_value;
            es_ms_o_data_rt <= ts_o_store_data;
            es_ms_o_addr_rd <= mx_es_o_addr_rd;
            es_pc_o_change_pc <= es_o_change_pc;
            es_ms_o_memtoreg <= ds_es_o_memtoreg;
            // es_ms_o_memread <= ds_es_o_memread;
            es_ms_o_memwrite <= ds_es_o_memwrite;
            ts_ms_o_store_mask <= ts_o_store_mask;
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
        // .m_rd_en(es_ms_o_memread),
        .m_i_ce(es_ms_o_ce), 
        .m_i_mask(ts_ms_o_store_mask),
        .alu_value_addr(es_ms_alu_value),
        .m_i_store_data(es_ms_o_data_rt), 
        .m_o_load_data(ms_o_load_data)
    );

    wire [`DWIDTH - 1 : 0] tl_o_load_data;
    treatload tl (
        .tl_i_opcode(es_ms_o_opcode), 
        .tl_i_load_data(ms_o_load_data), 
        .tl_o_load_data(tl_o_load_data)
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
        .es_ms_i_regwrite(es_ms_o_regwr), 
        .ms_wb_i_regwrite(ms_wb_o_regwr), 
        .ds_es_i_addr_rs1(ds_f_o_addr_rs), 
        .es_ms_i_addr_rd(es_ms_o_addr_rd), 
        .ms_wb_i_addr_rd(ms_wb_o_addr_rd), 
        .ds_es_i_addr_rs2(ds_es_o_addr_rt), 
        .f_o_control_rs1(forward_rs1), 
        .f_o_control_rs2(forward_rs2),
        .f_o_stall(f_o_stall)
    );

    assign write_back_data = (ms_wb_o_memtoreg) ? ms_wb_o_load_data : ms_wb_o_alu_value;
endmodule
`endif  
