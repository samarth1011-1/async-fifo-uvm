module wr_pointer_stable_when_full(
    input logic wr_clk, wr_rst_n, wr_en, full;
    input logic [4:0] wr_bin_ptr;

    property check_wr_ptr;
    @(posedge wr_clk) disable iff (!wr_rst_n)
    full |=> wr_bin_ptr == $past(wr_bin_ptr); // or also can be written as $stable(wr_bin_ptr)
    endproperty

    assert property(check_wr_ptr)
        else `uvm_error("Assertion Failed: Write pointer not stable when FIFO is full")
);
endmodule


module rd_pointer_stable_when_empty(
    input logic rd_clk, rd_rst_n, rd_en, empty;
    input logic [4:0] rd_bin_ptr;

    property check_rd_ptr;
    @(posedge rd_clk) disable iff (!rd_rst_n)
    empty |=> rd_bin_ptr == $past(rd_bin_ptr); // or also can be written as $stable(wr_bin_ptr)
    endproperty

    assert property(check_rd_ptr)
        else `uvm_error("Assertion Failed: Read pointer not stable when FIFO is empty")
);
endmodule

