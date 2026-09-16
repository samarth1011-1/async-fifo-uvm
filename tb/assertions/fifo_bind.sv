bind async_fifo wr_pointer_stable_when_full wr_ptr_assert_inst (
    .wr_clk     (wr_clk),
    .wr_rst_n   (wr_rst_n),
    .full       (full),
    .wr_bin_ptr (wr_bin_ptr)
);

bind async_fifo rd_pointer_stable_when_empty rd_ptr_assert_inst (
    .rd_clk     (rd_clk),
    .rd_rst_n   (rd_rst_n),
    .empty      (empty),
    .rd_bin_ptr (rd_bin_ptr)
);