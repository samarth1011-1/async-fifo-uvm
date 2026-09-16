class fifo_rd_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_rd_monitor)
  virtual read_if vif;
  uvm_analysis_port #(fifo_rd_item) rd_ap;

  covergroup rd_cg;
    option.per_instance = 1;
    cp_rd_en : coverpoint vif.rd_en;
    cp_empty : coverpoint vif.empty;
    cross_rd_empty : cross cp_rd_en, cp_empty;
  endgroup

  function new(string name = "fifo_rd_monitor", uvm_component parent);
    super.new(name, parent);
    rd_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rd_ap = new("rd_ap", this);
    if (!uvm_config_db #(virtual read_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_READ_VIF", "Monitor: Read interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_rd_item item;
    forever begin
      @(posedge vif.rd_clk);
      if (vif.rd_rst_n) rd_cg.sample();
      if (vif.rd_rst_n && vif.rd_en && !vif.empty) begin
        fifo_rd_item cloned_item;
        item = fifo_rd_item::type_id::create("item");
        item.rd_en = vif.rd_en;
        $cast(cloned_item, item.clone());
        fork
          begin
            @(posedge vif.rd_clk);
            cloned_item.data = vif.rd_data;
            rd_ap.write(cloned_item);
          end
        join_none
      end
    end
  endtask
endclass
