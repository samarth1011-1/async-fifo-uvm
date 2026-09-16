class fifo_drain_sequence extends uvm_sequence #(fifo_rd_item);
  `uvm_object_utils(fifo_drain_sequence)

  function new(string name = "fifo_drain_sequence");
    super.new(name);
endfunction

task body();
fifo_rd_item item;
 repeat(20)begin
    item = fifo_rd_item::type_id::create("item");
    start_item(item);
   assert(item.randomize() with {rd_en == 1;});
    finish_item(item);
 end
endtask

endclass