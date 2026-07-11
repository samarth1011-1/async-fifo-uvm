module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4, 
    parameter DEPTH = 16     // DEPTH = 2^ADDR_WIDTH
)(
   
    input wr_clk,
    input wr_rst_n,
    input wr_en,
    input [DATA_WIDTH-1:0] wr_data,
  
    input rd_clk,
    input rd_rst_n,
    input rd_en,
    output reg [DATA_WIDTH-1:0] rd_data,

    output reg full,
    output reg empty
);
  
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  
	reg [ADDR_WIDTH:0] wr_bin_ptr, rd_bin_ptr;
	wire [ADDR_WIDTH:0] wr_bin_next, rd_bin_next;

	reg [ADDR_WIDTH:0] wr_gray_ptr, rd_gray_ptr;
	wire [ADDR_WIDTH:0] wr_gray_next, rd_gray_next;

	wire [ADDR_WIDTH:0] wr_gray_sync1, wr_gray_sync2;
	wire [ADDR_WIDTH:0] rd_gray_sync1, rd_gray_sync2;

	wire [ADDR_WIDTH-1:0] wr_addr;
	wire [ADDR_WIDTH-1:0] rd_addr;

	wire wr_fire;
	wire rd_fire;

  assign wr_fire = wr_en && !full;
  assign rd_fire = rd_en && !empty;
  assign wr_addr = wr_bin_ptr[ADDR_WIDTH-1:0];
  assign rd_addr = rd_bin_ptr[ADDR_WIDTH-1:0];
  assign wr_bin_next = wr_bin_ptr + wr_fire;
  assign rd_bin_next = rd_bin_ptr + rd_fire;
  assign wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
  assign rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;

  
  rd_ff2_sync s1(.rd_clk(rd_clk),.rd_rst_n(rd_rst_n),.wr_gray_ptr(wr_gray_ptr),.wr_gray_sync1(wr_gray_sync1),.wr_gray_sync2(wr_gray_sync2));
  wr_ff2_sync sw(.wr_clk(wr_clk),.wr_rst_n(wr_rst_n),.rd_gray_ptr(rd_gray_ptr),.rd_gray_sync1(rd_gray_sync1),.rd_gray_sync2(rd_gray_sync2));
  

  // write clock
always@(posedge wr_clk or negedge wr_rst_n)begin
        if(!wr_rst_n)begin
            wr_bin_ptr<=0;
            wr_gray_ptr<=0;
            full<=0;
        end
        else begin
            if(wr_fire) begin
                mem[wr_addr] <= wr_data;
                wr_bin_ptr <= wr_bin_ptr+1;
                wr_gray_ptr <= ((wr_bin_ptr + 1) >> 1) ^ (wr_bin_ptr+1);
            end
        full<=(wr_gray_next == {~rd_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],rd_gray_sync2[ADDR_WIDTH-2:0]});
        end
end

  // read clock
always@(posedge rd_clk or negedge rd_rst_n)begin    
        if(!rd_rst_n)begin
            rd_bin_ptr<=0;
            rd_gray_ptr<=0;
            empty<=1;
        end
        else begin
            if(rd_fire) begin
                rd_data <= mem[rd_addr];
                rd_bin_ptr <= rd_bin_ptr + 1;
                rd_gray_ptr <= ((rd_bin_ptr + 1) >> 1) ^ (rd_bin_ptr+1);
            end
        empty<=(rd_gray_next == wr_gray_sync2);
        end
end  
endmodule



// read domain synchronizer
module rd_ff2_sync #(parameter ADDR_WIDTH=4)(
    input rd_clk,rd_rst_n,
    input [ADDR_WIDTH:0] wr_gray_ptr,
    output reg [ADDR_WIDTH:0] wr_gray_sync1,wr_gray_sync2
);
always@(posedge rd_clk or negedge rd_rst_n)begin
    if(!rd_rst_n)begin 
        wr_gray_sync1<=0;
        wr_gray_sync2<=0;
    end
    else begin
        wr_gray_sync1 <= wr_gray_ptr;
        wr_gray_sync2 <= wr_gray_sync1;
    end
end
endmodule

// write domain synchronizer
module wr_ff2_sync#(parameter ADDR_WIDTH=4)(
    input wr_clk,wr_rst_n,
    input [ADDR_WIDTH:0] rd_gray_ptr,
    output reg [ADDR_WIDTH:0] rd_gray_sync1,rd_gray_sync2
);
always@(posedge wr_clk or negedge wr_rst_n)begin
    if(!wr_rst_n)begin 
        rd_gray_sync1<=0;
        rd_gray_sync2<=0;
    end
    else begin
        rd_gray_sync1 <= rd_gray_ptr;
        rd_gray_sync2 <= rd_gray_sync1;
    end
end
endmodule