`ifndef TRANSMIT_V
`define TRANSMIT_V
`include "./source/header.vh"
module transmit (
    t_clk, t_rst, t_i_syn, t_o_instr, t_o_last, t_o_ack
);
    input t_clk, t_rst;
    input t_i_syn;
    output reg [`IWIDTH - 1 : 0] t_o_instr;
    output reg t_o_last, t_o_ack;
    integer counter;

    reg [`IWIDTH - 1 : 0] mem_instr [0 : `DEPTH - 1];

    always @(posedge t_clk, negedge t_rst) begin
        if (!t_rst) begin   
            $readmemh("./source/instr.txt", mem_instr, 0, `DEPTH - 1);
            counter <= 0;
            t_o_last <= 1'b0;
            t_o_instr <= {`IWIDTH{1'b0}};
            t_o_ack <= 1'b0;
        end
        else begin
            if (t_i_syn) begin
                t_o_instr <= mem_instr[counter];
                if (`DEPTH == 1) begin
                    t_o_last <= 1'b1;
                end
                else if (`DEPTH > 1) begin
                    t_o_last <= (counter == `DEPTH - 1) ? 1'b1 : 1'b0;
                end
                else begin
                    t_o_last <= 1'b0;
                end
                counter <= (counter < `DEPTH - 1) ? counter + 1 : 0;
                t_o_ack <= 1'b1;
                if (t_o_last) begin
                    t_o_ack <= 1'b0;
                end
            end
            else begin
                t_o_ack <= 1'b0;
                t_o_last <= 1'b0;
            end
        end
    end 
endmodule

`endif 