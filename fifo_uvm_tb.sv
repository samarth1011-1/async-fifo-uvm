`include "uvm_macros.svh"
import uvm_pkg::*;


// read interface
interface read_if(input logic rd_clk);
  logic rd_rst_n;
  logic rd_en;
  logic [7:0] rd_data;
  logic empty;

  property p_no_underflow;
    @(posedge rd_clk) disable iff (!rd_rst_n)
    empty |-> !rd_en;
  endproperty

  assert property(p_no_underflow)
    else `uvm_error("SVA_ERR", "Protocol Violation: Read attempted while FIFO is EMPTY!")
endinterface

// write interface
interface write_if(input logic wr_clk);
  logic wr_rst_n;
  logic wr_en;
  logic [7:0] wr_data;
  logic full;

  property p_no_overflow;
    @(posedge wr_clk) disable iff (!wr_rst_n)
    full |-> !wr_en;
  endproperty

  assert property(p_no_overflow)
    else `uvm_error("SVA_ERR", "Protocol Violation: Write attempted while FIFO is FULL!")
endinterface


// write transaction
class fifo_wr_item extends uvm_sequence_item;
  `uvm_object_utils(fifo_wr_item)
  randc logic [7:0] data;
  randc logic wr_en;

  function new(string name = "fifo_wr_item");
    super.new(name);
  endfunction
endclass


// read transaction
class fifo_rd_item extends uvm_sequence_item;
  `uvm_object_utils(fifo_rd_item)
  randc logic rd_en;
  logic [7:0] data;

  function new(string name = "fifo_rd_item");
    super.new(name);
  endfunction
endclass


// write sequence
class fifo_wr_sequence extends uvm_sequence #(fifo_wr_item);
  `uvm_object_utils(fifo_wr_sequence)

  function new(string name = "fifo_wr_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_wr_item item;
    repeat (100) begin
      item = fifo_wr_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {wr_en == 1;});
      finish_item(item);
    end
  endtask
endclass


// read sequence
class fifo_rd_sequence extends uvm_sequence #(fifo_rd_item);
  `uvm_object_utils(fifo_rd_sequence)

  function new(string name = "fifo_rd_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_rd_item item;
    repeat (100) begin
      item = fifo_rd_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {rd_en == 1;});
      finish_item(item);
    end
  endtask
endclass


// write sequencer
class fifo_wr_sequencer extends uvm_sequencer #(fifo_wr_item);
  `uvm_component_utils(fifo_wr_sequencer)

  function new(string name = "fifo_wr_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass


// read sequencer
class fifo_rd_sequencer extends uvm_sequencer #(fifo_rd_item);
  `uvm_component_utils(fifo_rd_sequencer)

  function new(string name = "fifo_rd_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass


// write driver
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
  vif.wr_en   <= 0;
  vif.wr_data <= 0;
  wait (vif.wr_rst_n == 1);
  forever begin
    seq_item_port.get_next_item(item);
    @(posedge vif.wr_clk);
    while (vif.full) begin
      vif.wr_en <= 0;
      @(posedge vif.wr_clk);
    end
    vif.wr_en   <= item.wr_en;
    vif.wr_data <= item.data;
    @(posedge vif.wr_clk);
    vif.wr_en <= 0;
    seq_item_port.item_done();
  end
endtask
endclass


// read driver
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
    while (vif.empty) begin
      vif.rd_en <= 0;
      @(posedge vif.rd_clk);
    end
    vif.rd_en <= item.rd_en;
    @(posedge vif.rd_clk);
    vif.rd_en <= 0;
    seq_item_port.item_done();
  end
endtask
endclass

// write monitor
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
        item.data  = vif.wr_data;
        item.wr_en = vif.wr_en;
        wr_ap.write(item);
      end
    end
  endtask
endclass


// read monitor
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

// write agent
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
      driver    = fifo_wr_driver::type_id::create("driver", this);
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

// read agent
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


`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

// scoreboard
class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp_wr #(fifo_wr_item, fifo_scoreboard) wr_export;
  uvm_analysis_imp_rd #(fifo_rd_item, fifo_scoreboard) rd_export;

  logic [7:0] ref_queue[$];

  int match_count = 0;
  int mismatch_count = 0;
  int wr_count = 0;
  int rd_count = 0;

  logic [7:0] cov_data;
  covergroup fifo_data_cg;
    option.per_instance = 1;
    cp_data : coverpoint cov_data {
      bins low_range  = {[8'h00 : 8'h55]};
      bins mid_range  = {[8'h56 : 8'hAA]};
      bins high_range = {[8'hAB : 8'hFF]};
    }
  endgroup

  function new(string name = "fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    fifo_data_cg = new(); 
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_export = new("wr_export", this);
    rd_export = new("rd_export", this);
  endfunction

  virtual function void write_wr(fifo_wr_item item);
    ref_queue.push_back(item.data);
    wr_count++;
    `uvm_info("SCB_WR", $sformatf("Captured Write Data: 0x%0h | Queue Depth: %0d", item.data, ref_queue.size()), UVM_HIGH)
  endfunction

  virtual function void write_rd(fifo_rd_item item);
    logic [7:0] expected_data;
    rd_count++;

    if (ref_queue.size() == 0) begin
      `uvm_error("SCB_UNDERFLOW", $sformatf("Read triggered but Reference Queue is EMPTY! Read Data: 0x%0h", item.data))
      mismatch_count++;
      return;
    end

    expected_data = ref_queue.pop_front();

    if (item.data === expected_data) begin
      match_count++;
      cov_data = expected_data;
      fifo_data_cg.sample();
      
      `uvm_info("SCB_MATCH", $sformatf("DATA MATCH: Expected = 0x%0h, Actual = 0x%0h", expected_data, item.data), UVM_MEDIUM)
    end else begin
      mismatch_count++;
      `uvm_error("SCB_MISMATCH", $sformatf("DATA MISMATCH! Expected = 0x%0h, Actual = 0x%0h", expected_data, item.data))
    end
  endfunction

  function void check_phase(uvm_phase phase);
    int total_tests = match_count + mismatch_count;
    int passed_tests = match_count;
    int failed_tests = mismatch_count;
    real data_coverage_pct = fifo_data_cg.get_inst_coverage();
    super.check_phase(phase);

    `uvm_info("SCB_REPORT", $sformatf({
      " Total Tests  : %0d\n",
      " Passed Tests : %0d\n",
      " Failed Tests : %0d\n",
      " Data Coverage  : %.2f%%\n"
    }, total_tests, passed_tests, failed_tests,data_coverage_pct), UVM_LOW)

    if (failed_tests > 0) begin
      `uvm_error("SCB_FAIL", $sformatf("Test FAILED with %0d mismatches!", failed_tests))
    end else begin
      `uvm_info("SCB_PASS", "Test PASSED: All transactions verified successfully!", UVM_LOW)
    end
  endfunction
endclass

    
    // env
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
    scb      = fifo_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rd_agent.monitor.rd_ap.connect(scb.rd_export);
    wr_agent.monitor.wr_ap.connect(scb.wr_export);
  endfunction
endclass


    // test
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


// top module
module tb_top;

  bit wr_clk;
  bit rd_clk;

  // 100 MHz clk
  always #5 wr_clk = ~wr_clk;

  // 40 MHz clk
  always #12.5 rd_clk = ~rd_clk;

  write_if w_if(wr_clk);
  read_if r_if(rd_clk);

  async_fifo dut (
    .wr_clk (w_if.wr_clk),
    .wr_rst_n (w_if.wr_rst_n),
    .wr_en (w_if.wr_en),
    .wr_data (w_if.wr_data),
    .full (w_if.full),

    .rd_clk (r_if.rd_clk),
    .rd_rst_n (r_if.rd_rst_n),
    .rd_en (r_if.rd_en),
    .rd_data (r_if.rd_data),
    .empty (r_if.empty)
  );

  initial begin
    w_if.wr_rst_n = 0;
    r_if.rd_rst_n = 0;
    w_if.wr_en = 0;
    w_if.wr_data = '0;
    r_if.rd_en = 0;

    #40;
    @(posedge wr_clk) w_if.wr_rst_n = 1;
    @(posedge rd_clk) r_if.rd_rst_n = 1;
  end

  initial begin
    uvm_config_db#(virtual write_if)::set(null, "*", "vif", w_if);
    uvm_config_db#(virtual read_if)::set(null, "*", "vif", r_if);

    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);

    run_test("fifo_random_test");
  end

endmodule