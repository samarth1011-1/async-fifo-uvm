`include "uvm_macros.svh"

module tb_top;

  import uvm_pkg::*;
  import fifo_pkg::*;

  bit wr_clk;
  bit rd_clk;

  // 100 MHz clk
  always #5 wr_clk = ~wr_clk;

  // 40 MHz clk
  always #12.5 rd_clk = ~rd_clk;

  write_if w_if(wr_clk);
  read_if r_if(rd_clk);

  async_fifo dut (
    .wr_clk (w_if.wr_clk),
    .wr_rst_n (w_if.wr_rst_n),
    .wr_en (w_if.wr_en),
    .wr_data (w_if.wr_data),
    .full (w_if.full),

    .rd_clk (r_if.rd_clk),
    .rd_rst_n (r_if.rd_rst_n),
    .rd_en (r_if.rd_en),
    .rd_data (r_if.rd_data),
    .empty (r_if.empty)
  );

  initial begin
    w_if.wr_rst_n = 0;
    r_if.rd_rst_n = 0;
    w_if.wr_en = 0;
    w_if.wr_data = '0;
    r_if.rd_en = 0;

    #40;
    @(posedge wr_clk) w_if.wr_rst_n = 1;
    @(posedge rd_clk) r_if.rd_rst_n = 1;
  end

  initial begin
    uvm_config_db#(virtual write_if)::set(null, "*", "vif", w_if);
    uvm_config_db#(virtual read_if)::set(null, "*", "vif", r_if);

    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);

    run_test("fifo_stress_test");
  end

endmodule
