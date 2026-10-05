`timescale 1ns / 1ps

module memory_ctrlr (
  input wire clk,
  input wire resetn,
  input wire start, //start the accumulation process
  output reg done, //goes high when all memory locations are processed
  output reg ena, //enable for port A
  output reg wea,// Write enable for port A
  output reg [7:0] addra, //Write address for port A
  output reg [15:0] dina,// data input for port A
  output reg enb, //enable for port B
  output reg [7:0] addrb, //read address for port B
  input wire [15:0] doutb // data output from port B
);
  reg [2:0] state; //FSM current state
  reg [15:0] acc_val; //running accumulated sum
  reg [15:0] rd_val;  //stores the data read from memory
  reg [7:0] addr_cnt; //address counter for traversing memory

  
localparam IDLE = 3'b000, WAIT_WRITE=3'b001, 
           READ = 3'b010, ACCUM = 3'b011, WRITE = 3'b100, DONE = 3'b101, CAPTURE= 3'b110;
 
  reg[1:0] read_wait;//counter to handle port B read latency = 2 cycles

  always @(posedge clk or negedge resetn) begin 
       if (!resetn) begin //reset all outputs, registers, and fsm state
          done <=0; ena<=0; 
          wea <=0; addra<=0; 
          dina<=0; enb<=0;  
          addrb<=0; state <=IDLE; 
          acc_val<=0; rd_val<=0; 
          addr_cnt<=0; read_wait<=0;
        end else begin //default outputs for each cycle ->asserted in a state
          ena<=0; wea<=0; enb<=0; done<=0;
           case (state) 
            IDLE: begin //initialize everything and wait for start
              addra<=0; addrb<=0; dina<=0; addr_cnt<=0;
              acc_val<=0; rd_val<=0;  read_wait<=0;
              if(start) begin 
                state <=READ; //begin first read
                read_wait<=2'b11; //wait 2 cycles for memory read latency
              end 
            end    
          READ: begin //stay here until latency counter expires
             enb<=1; 
             addrb<=addr_cnt; 
             if (read_wait!=0) begin
                read_wait<=read_wait-2'b01; 
                state <=READ; 
             end else begin  
             rd_val<=doutb;
             state <=ACCUM; //data should now be vaild
           
          end 
         end
             
          ACCUM: begin //add newly read value to running sum      
           
             acc_val<=acc_val+rd_val; 
             state <=WAIT_WRITE; 
          end 
          WAIT_WRITE: begin //prepare write signals for port A
            addra<=addr_cnt; //write result to same address
            state <=WRITE; 
            dina<=acc_val; //write accumulated
            ena<=1; //enable write port
            wea<=1; // assert write enable
            
          end     
          WRITE: begin //complete write and move to next address      
            if(addr_cnt==8'hFF) state <=DONE; 
            else begin 
              addr_cnt<=addr_cnt+1; //move to next address
              read_wait<=2'b11; //reload read latency counter
              state<= READ; 
            end
           end 
          DONE: begin 
          done<=1; 
          state <=DONE; 
          end 
          default : state <=IDLE; 
        endcase
     end 
   end 

endmodule
