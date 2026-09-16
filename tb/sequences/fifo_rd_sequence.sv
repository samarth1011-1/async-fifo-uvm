class fifo_rd_sequence extends uvm_sequence #(fifo_rd_item);
  `uvm_object_utils(fifo_rd_sequence)

  function new(string name = "fifo_rd_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_rd_item item;
    repeat (10000) begin
      item = fifo_rd_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {rd_en dist {1:=70, 0:=30};});
      finish_item(item);
    end
  endtask
endclass
