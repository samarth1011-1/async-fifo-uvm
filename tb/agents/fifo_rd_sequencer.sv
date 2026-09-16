class fifo_rd_sequencer extends uvm_sequencer #(fifo_rd_item);
  `uvm_component_utils(fifo_rd_sequencer)

  function new(string name = "fifo_rd_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
