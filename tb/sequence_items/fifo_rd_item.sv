class fifo_rd_item extends uvm_sequence_item;
  `uvm_object_utils(fifo_rd_item)
  rand logic rd_en;
  logic [7:0] data;

  function new(string name = "fifo_rd_item");
    super.new(name);
  endfunction
endclass
