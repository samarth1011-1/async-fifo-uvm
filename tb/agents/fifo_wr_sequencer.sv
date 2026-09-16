class fifo_wr_sequencer extends uvm_sequencer #(fifo_wr_item);
  `uvm_component_utils(fifo_wr_sequencer)

  function new(string name = "fifo_wr_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
