class fifo_fill_sequence extends uvm_sequence #(fifo_wr_item);
`uvm_object_utils(fifo_fill_sequence)

  function new(string name = "fifo_full_sequence");
    super.new(name);
endfunction

task body();
fifo_wr_item item;
 repeat(20)begin
    item = fifo_wr_item::type_id::create("item");
    start_item(item);
   assert(item.randomize() with {wr_en == 1;});
    finish_item(item);
 end
endtask

endclass