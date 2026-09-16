`include "uvm_macros.svh"
import uvm_pkg::*;

interface read_if(input logic rd_clk);
  logic rd_rst_n;
  logic rd_en;
  logic [7:0] rd_data;
  logic empty;


// checks underflow when fifo is empty
  property p_no_underflow;
    @(posedge rd_clk) disable iff (!rd_rst_n)
    empty |-> !rd_en;
  endproperty

  assert property(p_no_underflow)
    else `uvm_error("SVA_ERR", "Protocol Violation: Read attempted while FIFO is EMPTY!")


// checks empty is 1 after a reset
  property p_empty_rst;
  @(posedge wr_clk)
  !wr_rst_n |-> empty;
  endproperty

  assert property(p_empty_rst)
    else `uvm_error("SVA_ERR", "Protocol Violation: Empty flag did not Reset ")
endinterface
