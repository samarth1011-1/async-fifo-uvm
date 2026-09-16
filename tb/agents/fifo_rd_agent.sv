class fifo_rd_agent extends uvm_agent;
  `uvm_component_utils(fifo_rd_agent)
  fifo_rd_driver driver;
  fifo_rd_sequencer sequencer;
  fifo_rd_monitor monitor;

  function new(string name = "rd_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = fifo_rd_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      driver    = fifo_rd_driver::type_id::create("driver", this);
      sequencer = fifo_rd_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass
