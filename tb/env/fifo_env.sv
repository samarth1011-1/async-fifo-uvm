class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)
  fifo_rd_agent rd_agent;
  fifo_wr_agent wr_agent;
  fifo_scoreboard scb;

  function new(string name = "fifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rd_agent = fifo_rd_agent::type_id::create("rd_agent", this);
    wr_agent = fifo_wr_agent::type_id::create("wr_agent", this);
    scb = fifo_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rd_agent.monitor.rd_ap.connect(scb.rd_export);
    wr_agent.monitor.wr_ap.connect(scb.wr_export);
  endfunction
endclass
