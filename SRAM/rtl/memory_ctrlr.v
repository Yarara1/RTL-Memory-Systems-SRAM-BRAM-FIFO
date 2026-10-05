`timescale 1ns / 1ps

module memory_ctrlr#(
    parameter SRAM1_BW=16, //data width of sram1(16bit)
    parameter SRAM1_AMAX=256, //address locations
    parameter SRAM1_ADR= $clog2(SRAM1_AMAX), //address width from memory size
    parameter SRAM2_BW= 32, //data width of sram2(32bit)
    parameter SRAM2_AMAX= 192,//address locations
    parameter SRAM2_ADR= $clog2(SRAM2_AMAX) //address width from memory size
)(
    input wire clk,
    input wire resetn,//active low reset
    input wire start,//signal to start operation
    output reg done,//signal to finish operation
    output reg s1_en, output reg s2_en, //enable signals for sram1 and 2
    output reg s1_we,output reg s2_we, //write enable signals
    output reg [SRAM1_ADR-1:0] s1_addr,output reg [SRAM2_ADR-1:0] s2_addr,
    input wire [SRAM1_BW-1:0] s1_dout, //data read from sram1
    output reg [SRAM2_BW-1:0] s2_din //data written to sram2
);

reg [2:0] state;

localparam IDLE = 3'b000,
           WAIT_READ = 3'b001, //wait state before reading sram1
           WAIT_WRITE= 3'b101, //wait state before writing sram2
           READ = 3'b010, //read data from sram1
           WRITE = 3'b011,//write data to sram2
           DONE = 3'b100;//operationg complete

//seq block -> FSM+outputs
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      //reset all control signals and registers
        s1_en <=0; s2_en <=0;
        s1_we<=0;s2_we<=0;
        s1_addr<=0;s2_addr<=0;
        s2_din<=0; done <=0;
        state <=IDLE;
    end
    else begin
        case (state)
            IDLE: begin
          //diable both memories
                s1_en<=0;s2_en<=0;
                s1_we<=0;s2_we<=0;
         //initialize addresses-> sram1 reading start from 128, sram2 from 0
                s1_addr<=8'h80; s2_addr<=0;
                done <=0;
                if (start) begin //wait for start signal
                    state <= WAIT_READ;
                end
            end
        
            WAIT_READ: begin
                s1_en <=1; //enable sram1 before actual read (latency handling)
                s1_we<=0; //set to read mode
                state <=READ;
            end

            WAIT_WRITE: begin
                s2_en <=1; //enable sram2 before writing
                s2_we<=1; //set to write mode
                state <=WRITE;
            end

            READ: begin
                s1_en<=0; //disable sram1 after read
                if (s1_addr[0] ==0)  //even numbers in binary always end in 0
                    s2_din <= {16'h0000,s1_dout}; //if address is even-> place data in lower 16bits
                
                else 
                    s2_din <= {s1_dout,16'h00000};//if address is odd ->place data in upper 16 bit
           state <= WAIT_WRITE ;     
            end

            WRITE: begin
                s2_en<=0; //disable sram2 after write
                s2_we<=0;
                //if last address is reached -> finish operation
                if (s1_addr == 8'hFF) state <= DONE; 
                else begin
                //if not reached -> increment address
                    s1_addr<=s1_addr+1;
                    s2_addr<=s2_addr+1;
                    state <= WAIT_READ;
                end
            end

            DONE: begin
                done <=1; //raise done flag
                state <= DONE; //remain in DONE state
            end

            default : state <= IDLE;
        endcase
    end
end

endmodule
