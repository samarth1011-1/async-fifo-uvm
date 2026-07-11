`timescale 1ns/1ps

class tb_fifo #(parameter DATA_WIDTH = 8);
    randc bit                  wr_en;
    randc bit [DATA_WIDTH-1:0] wr_data;
    randc bit                  rd_en;
endclass

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH      = 16;

    logic wr_clk;
    logic wr_rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;

    logic rd_clk;
    logic rd_rst_n;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;

    logic full;
    logic empty;

    // DUT
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),

        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),

        .full(full),
        .empty(empty)
    );

    logic [DATA_WIDTH-1:0] ref_q[$];
    logic [DATA_WIDTH-1:0] expected;

    tb_fifo #(DATA_WIDTH) wr_stim;
    tb_fifo #(DATA_WIDTH) rd_stim;

    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;

    initial rd_clk = 0;
    always #7 rd_clk = ~rd_clk;

    initial begin
        wr_stim = new();
        rd_stim = new();

        wr_rst_n = 0;
        rd_rst_n = 0;
        wr_en    = 0;
        rd_en    = 0;
        wr_data  = 0;

        #30;

        wr_rst_n = 1;
        rd_rst_n = 1;
    end

    always @(posedge wr_clk) begin
        if (!wr_rst_n) begin
            wr_en   <= 0;
            wr_data <= 0;
        end
        else begin
            if (!wr_stim.randomize()) $fatal("wr_stim randomize failed");
            wr_en <= wr_stim.wr_en;
            wr_data <= wr_stim.wr_data;
            if (wr_en && !full) begin
                ref_q.push_back(wr_data);
                $display("[%0t] WRITE : %0d", $time, wr_data);
            end
        end
    end

    always @(posedge rd_clk) begin
        if (!rd_rst_n) rd_en <= 0;
        else begin
            if (!rd_stim.randomize()) $fatal("rd_stim randomize failed");
            
            rd_en <= rd_stim.rd_en;

            if (rd_en && !empty) begin
                expected = ref_q.pop_front();
                #1;   
                $display("[%0t] READ : %0d",$time,expected);
                if (rd_data !== expected) begin
                    $display("[%0t] FAIL  Expected=%0d  Got=%0d",$time, expected, rd_data);
                    $stop;
                end
                else $display("[%0t] PASS  Data=%0d", $time, rd_data);
            end
        end
    end

    initial begin
        #5000;

        if (ref_q.size() != 0) $display("Reference Queue still has %0d entries.", ref_q.size());

        $display("Simulation Finished.");
        $finish;
    end

endmodule