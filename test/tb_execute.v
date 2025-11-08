`include "./source/execute_stage.v"

module tb;

    // 2. KHAI BÁO TÍN HIỆU
    // Thêm clock và reset
    reg clk;
    reg rst;

    // Inputs (tất cả đều là reg)
    reg es_i_ce;
    reg es_i_alu_src;
    reg [`JUMP_WIDTH - 1 : 0] es_i_jal_addr;
    reg es_i_jal;
    reg es_i_jr; // <-- PORT BỊ THIẾU TRONG TESTBENCH CŨ CỦA BẠN
    reg [`PC_WIDTH - 1 : 0] es_i_pc;
    reg [`IMM_WIDTH - 1 : 0] es_i_imm;
    reg [`OPCODE_WIDTH - 1 : 0] es_i_alu_op;
    reg [`FUNCT_WIDTH - 1 : 0] es_i_alu_funct;
    reg [`DWIDTH - 1 : 0] es_i_data_rs, es_i_data_rt;
    
    // Outputs (tất cả đều là wire)
    wire [`DWIDTH - 1 : 0] es_o_alu_value;
    wire [`PC_WIDTH - 1 : 0] es_o_alu_pc;
    wire [`OPCODE_WIDTH - 1 : 0] es_o_opcode;
    wire es_o_ce;
    wire es_o_change_pc;

    // 3. KHỞI TẠO MODULE CẦN KIỂM TRA (UUT - Unit Under Test)
    // Đảm bảo kết nối TẤT CẢ các cổng
    execute uut (
        .es_i_ce(es_i_ce),
        .es_i_jr(es_i_jr),         // <-- KẾT NỐI PORT BỊ THIẾU
        .es_i_jal(es_i_jal),
        .es_i_jal_addr(es_i_jal_addr),
        .es_i_pc(es_i_pc),
        .es_i_alu_src(es_i_alu_src),
        .es_i_imm(es_i_imm),
        .es_i_alu_op(es_i_alu_op),
        .es_i_alu_funct(es_i_alu_funct),
        .es_i_data_rs(es_i_data_rs),
        .es_i_data_rt(es_i_data_rt),

        .es_o_alu_value(es_o_alu_value),
        .es_o_ce(es_o_ce),
        .es_o_opcode(es_o_opcode),
        .es_o_change_pc(es_o_change_pc),
        .es_o_alu_pc(es_o_alu_pc)
    );

    // 4. TẠO CLOCK
    parameter CLK_PERIOD = 10;
    initial begin
        clk = 0;
        es_i_ce       = 1'b0;
        es_i_jr       = 1'b0;
        es_i_jal      = 1'b0;
        es_i_jal_addr = 0;
        es_i_alu_src  = 1'b0;
        es_i_pc       = 0;
        es_i_imm      = 0;
        es_i_alu_op   = 0; // Giả sử 0 là `NOP`
        es_i_alu_funct= 0;
        es_i_data_rs  = 0;
        es_i_data_rt  = 0;
    end
    always #(CLK_PERIOD / 2) clk = ~clk;

    // 5. THIẾT LẬP VCD DUMP VÀ MONITOR
    initial begin
        $dumpfile("./waveform/execute.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        $monitor($time, " [IN] pc=%d imm=%d rs=%d rt=%d op=%b funct=%b | [OUT] alu_val=%d alu_pc=%d change_pc=%b ce=%b",
            es_i_pc, es_i_imm, es_i_data_rs, es_i_data_rt, es_i_alu_op, es_i_alu_funct,
            es_o_alu_value, es_o_alu_pc, es_o_change_pc, es_o_ce);
    end
    
    // 6. TÁC VỤ (TASK) HỖ TRỢ
    // Task đợi 1 chu kỳ clock
    task tick;
        @(posedge clk);
    endtask

    // 7. KHỐI KÍCH THÍCH (STIMULUS) CHÍNH
    initial begin
        // Khởi tạo và Reset
        rst = 1'b1;
        es_i_ce = 1'b0; // Giữ ce=0 trong khi reset
        tick();
        rst = 1'b0;
        tick();

        // TEST 1: OR (R-Type) 5 | 4 = 5
        es_i_ce = 1'b1;
        es_i_data_rs = 5;
        es_i_data_rt = 4;
        es_i_alu_op = `RTYPE;
        es_i_alu_funct = `OR;
        tick();

        // TEST 2: SUB (R-Type) 10 - 4 = 6
        es_i_ce = 1'b1;
        es_i_data_rs = 10;
        es_i_data_rt = 4;
        es_i_alu_op = `RTYPE;
        es_i_alu_funct = `SUB; // Giả sử bạn có `SUB`
        tick();
        
        // TEST 3: BEQ (Branch) - rs == rt (5 == 5), pc = 10, imm = 10
        // (Module 'execute' của bạn không có `es_i_branch`,
        // nhưng module 'alu' bên trong có vẻ có logic 'change_pc' cho branch)
        es_i_ce = 1'b1;
        es_i_pc = 10;
        es_i_imm = 10; // offset
        es_i_data_rs = 5;
        es_i_data_rt = 5;
        es_i_alu_op = `BEQ;
        tick();

        // TEST 4: JAL
        es_i_ce = 1'b1;
        es_i_pc = 50;
        es_i_jal = 1'b1;
        es_i_jal_addr = 1000; // Địa chỉ jump
        tick();

        // Kết thúc mô phỏng
        tick();
        tick();
        $finish;
    end

endmodule