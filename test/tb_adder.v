`include "./source/control_hazard.v"

module tb;
    reg [`PC_WIDTH - 1 : 0] i_pc;
    reg [`IMM_WIDTH - 1 : 0] i_imm;
    reg i_branch;
    reg [`OPCODE_WIDTH - 1 : 0] i_opcode;
    reg [`DWIDTH - 1 : 0] i_data_r1, i_data_r2;
    wire [`PC_WIDTH - 1 : 0] o_pc;
    wire o_compare;

    control_hazard a (
        .i_pc(i_pc), 
        .i_imm(i_imm), 
        .i_branch(i_branch), 
        .i_opcode(i_opcode), 
        .i_data_r1(i_data_r1), 
        .i_data_r2(i_data_r2), 
        .o_pc(o_pc), 
        .o_compare(o_compare)
    );

    initial begin
        i_pc = {`PC_WIDTH{1'b0}};
        i_imm = {`IMM_WIDTH{1'b0}}; 
        i_branch = 1'b0; 
        i_opcode = {`OPCODE_WIDTH{1'b0}};
        i_data_r1 = {`DWIDTH{1'b0}};
        i_data_r2 = {`DWIDTH{1'b0}};
    end

    initial begin
        #10;
            i_pc = 10;
            i_imm = 10; 
            i_branch = 1'b1; 
            i_opcode = `BEQ;
            i_data_r1 = 10;
            i_data_r2 = 10;
        #10;
            i_pc = 10;
            i_imm = 10; 
            i_branch = 1'b1; 
            i_opcode = `BNE;
            i_data_r1 = 11;
            i_data_r2 = 10;
        #10; $finish;
    end

    initial begin
        $monitor($time, " ", " o_pc = %d, o_compare = %b", o_pc, o_compare);
    end
endmodule