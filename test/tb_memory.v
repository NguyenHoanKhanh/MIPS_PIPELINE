`timescale 1ns/1ps
`include "./source/memory.v"

module tb;
    reg m_clk, m_rst;
    reg m_wr_en;
    reg m_i_ce;
    reg [`AWIDTH_MEM - 1 : 0] alu_value_addr;
    reg [`DWIDTH - 1 : 0] m_i_store_data;
    reg [3 : 0] m_i_mask;
    wire [`DWIDTH - 1 : 0] m_o_load_data;
    integer i;

    memory m (
        .m_clk(m_clk), 
        .m_rst(m_rst), 
        .m_wr_en(m_wr_en), 
        .m_i_ce(m_i_ce), 
        .alu_value_addr(alu_value_addr),
        .m_i_store_data(m_i_store_data),
        .m_i_mask(m_i_mask),  
        .m_o_load_data(m_o_load_data)
    );

    // Clock 10ns
    initial begin
        m_clk = 1'b0;
        forever #5 m_clk = ~m_clk;
    end

    // Dump waveform
    initial begin
        $dumpfile("./waveform/memory.vcd");
        $dumpvars(0, tb);
    end

    // Reset task
    task reset (input integer cycles);
        begin
            m_rst = 1'b0;
            repeat(cycles) @(posedge m_clk);
            m_rst = 1'b1;
            @(posedge m_clk);
        end
    endtask

    // Task ghi dữ liệu với mask
    task store_data(input [3:0] mask, input [31:0] data, input [31:0] addr);
        begin
            @(posedge m_clk);
            m_i_ce = 1'b1;
            m_wr_en = 1'b1;
            m_i_mask = mask;
            alu_value_addr = addr;
            m_i_store_data = data;
            @(posedge m_clk);
            m_wr_en = 1'b0;
        end
    endtask

    // Task đọc dữ liệu
    task load_data(input [31:0] addr);
        begin
            @(posedge m_clk);
            m_i_ce = 1'b1;
            alu_value_addr = addr;
            @(posedge m_clk);
            $display("[%0t] Addr=%0d => Load Data=0x%08h", $time, alu_value_addr, m_o_load_data);
        end
    endtask

    initial begin
        // Reset memory
        reset(2);

        // --- TEST 1: STORE WORD (ghi đủ 4 byte) ---
        $display("\n==== TEST 1: STORE WORD ====");
        store_data(4'b1111, 32'hAABBCCDD, 3);
        load_data(3);

        // --- TEST 2: STORE HALF (ghi 2 byte thấp) ---
        $display("\n==== TEST 2: STORE HALF ====");
        store_data(4'b0011, 32'h0000EEFF, 4);
        load_data(4);

        // --- TEST 3: STORE BYTE (ghi 1 byte thấp) ---
        $display("\n==== TEST 3: STORE BYTE ====");
        store_data(4'b0001, 32'h00000099, 5);
        load_data(5);

        // --- TEST 4: GHI NHIỀU GIÁ TRỊ ---
        $display("\n==== TEST 4: MULTI WRITE LOOP ====");
        for (i = 0; i < 8; i = i + 1) begin
            store_data(4'b1111, i * 16 + 8, i);
        end
        for (i = 0; i < 8; i = i + 1) begin
            load_data(i);
        end

        $display("\nSimulation Done.\n");
        #50 $finish;
    end
endmodule
