class fifo_wr_sequence extends uvm_sequence #(fifo_wr_item);
  `uvm_object_utils(fifo_wr_sequence)

  function new(string name = "fifo_wr_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_wr_item item;
    repeat (10000) begin
      item = fifo_wr_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {wr_en dist {1:=70, 0:=30};});
      finish_item(item);
    end
  endtask
endclass
