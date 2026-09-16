class fifo_random_test extends uvm_test;
  `uvm_component_utils(fifo_random_test)

  fifo_env env;

  function new(string name = "fifo_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_wr_sequence wr_seq;
    fifo_rd_sequence rd_seq;

    wr_seq = fifo_wr_sequence::type_id::create("wr_seq");
    rd_seq = fifo_rd_sequence::type_id::create("rd_seq");

    phase.raise_objection(this);

    fork
      wr_seq.start(env.wr_agent.sequencer);
      rd_seq.start(env.rd_agent.sequencer);
    join

    #100ns;

    phase.drop_objection(this);
  endtask
endclass
