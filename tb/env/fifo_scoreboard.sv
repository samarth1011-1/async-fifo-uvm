`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

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
      bins low_range = {[8'h00 : 8'h55]};
      bins mid_range = {[8'h56 : 8'hAA]};
      bins high_range = {[8'hAB : 8'hFF]};
    }
  endgroup

  int occupancy;

  covergroup fifo_occupancy_cg;
    option.per_instance = 1;

    cp_occupancy : coverpoint occupancy {
      bins empty = {0};
      bins low = {[1:5]};
      bins mid = {[6:10]};
      bins high = {[11:15]};
      bins full = {16};
    }
  endgroup

  function new(string name = "fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    fifo_data_cg = new();
    fifo_occupancy_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_export = new("wr_export", this);
    rd_export = new("rd_export", this);
  endfunction

  virtual function void write_wr(fifo_wr_item item);

    ref_queue.push_back(item.data);
    wr_count++;

    occupancy = ref_queue.size();
    fifo_occupancy_cg.sample();

    `uvm_info("SCB_WR",$sformatf("Captured Write Data: 0x%0h | Queue Depth: %0d",item.data,ref_queue.size()),UVM_HIGH)
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
    occupancy = ref_queue.size();
    fifo_occupancy_cg.sample();

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
    real occupancy_coverage_pct = fifo_occupancy_cg.get_inst_coverage();
    super.check_phase(phase);

`uvm_info("SCB_REPORT", $sformatf({
    " Writes Captured    : %0d\n",
    " Reads Captured     : %0d\n",
    " Matches            : %0d\n",
    " Mismatches         : %0d\n",
    " Queue Leftover     : %0d\n",
    " Data Coverage      : %.2f%%\n",
    " Occupancy Coverage : %.2f%%\n"
},
    wr_count,
    rd_count,
    match_count,
    mismatch_count,
    ref_queue.size(),
    data_coverage_pct,
    occupancy_coverage_pct
), UVM_LOW)

    if(failed_tests > 0) begin
      `uvm_error("SCB_FAIL", $sformatf("Test FAILED with %0d mismatches!", failed_tests))
    end else begin
      `uvm_info("SCB_PASS", "Test PASSED: All transactions verified successfully!", UVM_LOW)
    end
  endfunction
endclass