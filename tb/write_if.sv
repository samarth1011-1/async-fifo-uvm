`include "uvm_macros.svh"
import uvm_pkg::*;

interface write_if(input logic wr_clk);
  logic wr_rst_n;
  logic wr_en;
  logic [7:0] wr_data;
  logic full;


// checks overflow when fifo is full
  property p_no_overflow;
    @(posedge wr_clk) disable iff (!wr_rst_n)
    full |-> !wr_en;
  endproperty

  assert property(p_no_overflow)
    else `uvm_error("SVA_ERR", "Protocol Violation: Write attempted while FIFO is FULL!")

// checks full is 0 after a reset
  property p_full_rst;
  @(posedge wr_clk)
  !wr_rst_n |-> !full;
  endproperty

  assert property(p_full_rst)
    else `uvm_error("SVA_ERR", "Protocol Violation: Full flag did not Reset ")
endinterface
