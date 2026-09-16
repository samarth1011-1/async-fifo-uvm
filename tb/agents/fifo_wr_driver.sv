class fifo_wr_driver extends uvm_driver #(fifo_wr_item);
  `uvm_component_utils(fifo_wr_driver)
  virtual write_if vif;

  function new(string name = "fifo_wr_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual write_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_WRITE_VIF", "Driver: Write interface not found")
  endfunction

  task run_phase(uvm_phase phase);

  fifo_wr_item item;

  vif.wr_en <= 0;
  vif.wr_data <= 0;

  wait (vif.wr_rst_n == 1);
  forever begin
    seq_item_port.get_next_item(item);

    @(posedge vif.wr_clk);

    if (item.wr_en && !vif.full) begin
      vif.wr_en <= 1;
      vif.wr_data <= item.data;
    end
    else begin
      vif.wr_en <= 0;
    end

    @(posedge vif.wr_clk);

    vif.wr_en <= 0;

    seq_item_port.item_done();

  end

endtask
endclass
