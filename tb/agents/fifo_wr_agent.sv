class fifo_wr_agent extends uvm_agent;
  `uvm_component_utils(fifo_wr_agent)
  fifo_wr_driver driver;
  fifo_wr_sequencer sequencer;
  fifo_wr_monitor monitor;

  function new(string name = "wr_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = fifo_wr_monitor::type_id::create("monitor", this);
    if (get_is_active() == UVM_ACTIVE) begin
      driver = fifo_wr_driver::type_id::create("driver", this);
      sequencer = fifo_wr_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass
