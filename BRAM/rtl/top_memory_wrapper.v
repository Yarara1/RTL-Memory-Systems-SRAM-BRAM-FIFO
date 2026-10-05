`timescale 1ns / 1ps

module top_memory_wrapper(
    input wire clk, input wire resetn,
    input wire start, output wire done,
    input wire ext_enb,input wire [7:0] ext_addrb,
    output wire [15:0] ext_doutb
    );  
    wire ena; wire wea;
    wire [7:0] addra;
    wire [15:0] dina;  
    wire enb; wire [7:0] addrb;
    wire [15:0] doutb;
    wire int_enb; wire [7:0] int_addrb;
    wire [15:0] int_doutb;

    assign enb = (done)? ext_enb: int_enb;
    assign addrb = (done)? ext_addrb: int_addrb;
    assign ext_doutb = doutb;

    memory_ctrlr Umemory_ctrlr(
      .clk(clk),
      .resetn(resetn),.start(start),
      .done(done),.ena(ena),
      .wea(wea),.addra(addra),
      .dina(dina), .enb(int_enb),
      .addrb(int_addrb),.doutb(doutb)
    );
    blk_mem_gen_0 UBRAM(
        .clka(clk),.ena(ena), 
        .wea(wea),.addra(addra), 
        .dina(dina),.clkb(clk), 
        .enb(enb),.addrb(addrb), 
        .doutb(doutb)
      );
    
endmodule 
