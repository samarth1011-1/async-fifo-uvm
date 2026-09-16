class fifo_wr_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_wr_monitor)
  virtual write_if vif;
  uvm_analysis_port #(fifo_wr_item) wr_ap;

  covergroup wr_cg;
    option.per_instance = 1;
    cp_wr_en : coverpoint vif.wr_en;
    cp_full  : coverpoint vif.full;
    cross_wr_full : cross cp_wr_en, cp_full;
  endgroup

  function new(string name = "fifo_wr_monitor", uvm_component parent);
    super.new(name, parent);
    wr_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_ap = new("wr_ap", this);
    if (!uvm_config_db #(virtual write_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_WRITE_VIF", "Monitor: Write interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_wr_item item;
    forever begin
      @(posedge vif.wr_clk);
      if (vif.wr_rst_n) wr_cg.sample();
      if (vif.wr_rst_n && vif.wr_en && !vif.full) begin
        item = fifo_wr_item::type_id::create("item");
        item.data = vif.wr_data;
        item.wr_en = vif.wr_en;
        wr_ap.write(item);
      end
    end
  endtask
endclass
