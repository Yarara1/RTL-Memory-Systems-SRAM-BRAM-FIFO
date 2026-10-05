module fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8  
    )(
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        wren_i,
    input   wire                        rden_i,
    input   wire    [DATA_WIDTH-1:0]    wdata_i,
    output  wire    [DATA_WIDTH-1:0]    rdata_o,
    output  wire                        full_o,
    output  wire                        empty_o
    );
    
    localparam FIFO_DEPTH_LG2 = $clog2(FIFO_DEPTH);
    
    reg [FIFO_DEPTH_LG2:0] wrptr;
    reg [FIFO_DEPTH_LG2:0] rdptr;
 
    // Full & empty check
    assign empty_o  =   (wrptr==rdptr);
    assign full_o   =   (wrptr[FIFO_DEPTH_LG2-1:0]==rdptr[FIFO_DEPTH_LG2-1:0]) & 
                        (wrptr[FIFO_DEPTH_LG2] != rdptr[FIFO_DEPTH_LG2]);

    // Write pointer counter seq logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wrptr <= {(FIFO_DEPTH_LG2+1){1'b0}};
        end 
        else if (wren_i) begin
            wrptr <= wrptr + 'd1;
        end
        else begin
            wrptr <= wrptr;
        end
    end
    
    // Read pointer counter seq logic   
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rdptr <= {(FIFO_DEPTH_LG2+1){1'b0}};
        end 
        else if (rden_i) begin
            rdptr <= rdptr + 'd1;
        end
        else begin
            rdptr <= rdptr;
        end
    end
    
    fifo_mem UMEM(
        .clka(clk), 
        .ena(wren_i), 
        .wea(wren_i), 
        .addra(wrptr[FIFO_DEPTH_LG2-1:0]), 
        .dina(wdata_i), 
        .clkb(clk), 
        .enb(rden_i), 
        .addrb(rdptr[FIFO_DEPTH_LG2-1:0]), 
        .doutb(rdata_o)
    );

endmodule
