`timescale 1ns / 1ps

module line_buffer#(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,    //  2, 4, 8 ... 
    parameter NUM_FIFO   = 3
    )(
    input   wire    clk,
    input   wire    resetn,
    output  reg    ready, //indicates when all fifos are filled and data can be read
    input   wire    wren_i, //external write enable 
    input   wire    rden_i, // external read enable
    input   wire    [DATA_WIDTH-1:0]    data_in, //input data to be stored
    output  wire    [3*DATA_WIDTH-1:0]    data_out //concantenated outputs of the 3 fifos
    );  
    //status signals from each fifo  
    wire full_0, full_1, full_2;
    wire empty_0, empty_1, empty_2;
    reg [1:0] state; 
    //read data outputs from each fifo
    wire [DATA_WIDTH-1:0] fifo0_rdata; 
    wire [DATA_WIDTH-1:0] fifo1_rdata; 
    wire [DATA_WIDTH-1:0] fifo2_rdata; 
    //internal write and read enables for each fifo
    reg wren_0, wren_1, wren_2;
    reg rden_0, rden_1, rden_2;
    
  localparam IDLE =2'b00 ,  WRITE=2'b01, READ=2'b10;
  //combine the outputs of all 3 fifos into one bus
 assign data_out = {fifo2_rdata, fifo1_rdata, fifo0_rdata};
 //seq FSM to control state transitions and ready flag
    always @(posedge clk or negedge resetn) begin 
        if (!resetn) begin 
            state <= IDLE; 
            ready <= 0;
        end else begin
            case (state) 
                IDLE: begin 
                    ready <= 0; //wait for first write request
                    if (wren_i) state <= WRITE;              
                end 
                
                WRITE: begin 
                    ready <= 0;
                    // Transition to READ once all FIFOs have been filled
                    if (full_0 && full_1 && full_2) begin
                        ready <= 1;
                        state <= READ;
                    end
                end

                READ: begin 
                    ready <= 1;
                    // Transition to IDLE once all data has been read        
                    if (empty_0 && empty_1 && empty_2) begin
                        ready <= 0;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase 
        end 
    end 
   // Combinational logic to generate write/read enables for each fifo based on state
   always @(*) begin
    wren_0 = 1'b0; wren_1 = 1'b0; wren_2 = 1'b0;
    rden_0 = 1'b0; rden_1 = 1'b0; rden_2 = 1'b0;

    case (state)
        IDLE: begin
            if (wren_i) //In IDLE, first incoming data goes to FIFO0
                wren_0 = 1'b1;
        end
       //write sequentially into fifo0, then fifo1, and then fifo2
        WRITE: begin
            if (!full_0)
                wren_0 = wren_i;
            else if (!full_1)
                wren_1 = wren_i;
            else if (!full_2)
                wren_2 = wren_i;
        end
       // read from all fifos simultaneously only if external read is active and ready is high and all full
        READ: begin
            if (rden_i && ready && !empty_0 && !empty_1 && !empty_2) begin
                rden_0 = 1'b1;
                rden_1 = 1'b1;
                rden_2 = 1'b1;
            end
        end
    endcase
end
   //FIFO instances
    fifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) Ufifo_0 (
        .clk     (clk),
        .rst_n   (resetn),
        .wren_i  (wren_0),
        .rden_i  (rden_0),
        .wdata_i (data_in),
        .rdata_o (fifo0_rdata),
        .full_o  (full_0),
        .empty_o (empty_0)
    );
    fifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) Ufifo_1 (
        .clk     (clk),
        .rst_n   (resetn),
        .wren_i  (wren_1),
        .rden_i  (rden_1),
        .wdata_i (data_in),
        .rdata_o (fifo1_rdata),
        .full_o  (full_1),
        .empty_o (empty_1)
    );
    fifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) Ufifo_2 (
        .clk     (clk),
        .rst_n   (resetn),
        .wren_i  (wren_2),
        .rden_i  (rden_2),
        .wdata_i (data_in),
        .rdata_o (fifo2_rdata),
        .full_o  (full_2),
        .empty_o (empty_2)
    );

endmodule
