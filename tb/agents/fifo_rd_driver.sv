class fifo_rd_driver extends uvm_driver #(fifo_rd_item);
  `uvm_component_utils(fifo_rd_driver)
  virtual read_if vif;

  function new(string name = "fifo_rd_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual read_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_READ_VIF", "Driver: Read interface not found")
  endfunction

  task run_phase(uvm_phase phase);

  fifo_rd_item item;

  vif.rd_en <= 0;

  wait (vif.rd_rst_n == 1);

  forever begin

    seq_item_port.get_next_item(item);

    @(posedge vif.rd_clk);

    if (item.rd_en && !vif.empty) begin
      vif.rd_en <= 1;
    end
    else begin
      vif.rd_en <= 0;
    end

    @(posedge vif.rd_clk);

    vif.rd_en <= 0;

    seq_item_port.item_done();

  end

endtask
endclass
