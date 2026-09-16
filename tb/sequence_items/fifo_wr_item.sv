class fifo_wr_item extends uvm_sequence_item;
  `uvm_object_utils(fifo_wr_item)
  randc logic [7:0] data;
  rand logic wr_en;

  function new(string name = "fifo_wr_item");
    super.new(name);
  endfunction
endclass
