package fifo_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "sequence_items/fifo_wr_item.sv"
  `include "sequence_items/fifo_rd_item.sv"

  `include "sequences/fifo_wr_sequence.sv"
  `include "sequences/fifo_rd_sequence.sv"
  `include "sequences/fifo_drain_sequence.sv"
  `include "sequences/fifo_fill_sequence.sv"

  `include "agents/fifo_wr_sequencer.sv"
  `include "agents/fifo_rd_sequencer.sv"
  `include "agents/fifo_wr_driver.sv"
  `include "agents/fifo_rd_driver.sv"
  `include "agents/fifo_wr_monitor.sv"
  `include "agents/fifo_rd_monitor.sv"
  `include "agents/fifo_wr_agent.sv"
  `include "agents/fifo_rd_agent.sv"

  `include "env/fifo_scoreboard.sv"
  `include "env/fifo_env.sv"

  `include "tests/fifo_random_test.sv"
  `include "tests/fifo_empty_test.sv"
  `include "tests/fifo_fill_test.sv"
  `include "tests/fifo_stress_test.sv"
  

endpackage
