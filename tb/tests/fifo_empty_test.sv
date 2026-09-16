class fifo_empty_test extends uvm_test;
    `uvm_component_utils(fifo_empty_test)

    fifo_env env;

    function new(string name = "fifo_empty_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_drain_sequence drain_seq;
        fifo_fill_sequence fill_seq;

        fill_seq = fifo_fill_sequence::type_id::create("fill_seq");
        drain_seq = fifo_drain_sequence::type_id::create("drain_seq");

        phase.raise_objection(this);

        fill_seq.start(env.wr_agent.sequencer);
        drain_seq.start(env.rd_agent.sequencer);

        #100ns;

        phase.drop_objection(this);
    endtask

endclass