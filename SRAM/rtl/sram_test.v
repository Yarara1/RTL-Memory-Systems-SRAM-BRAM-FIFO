`timescale 1ns / 1ps

module sram_test #(
  parameter BW = 32,
  parameter AMAX = 512,
  parameter ADR = $clog2(AMAX)
)(
  input wire clk,
  input wire en,
  input wire we,
  input wire [ADR-1:0] addr,
  input wire [BW-1:0] din,
  output wire [BW-1:0] dout
);
  reg [BW-1:0] mem [0:AMAX-1];

  always @(posedge clk) begin
    if(en) begin
      if(we) begin
        mem[addr] <= #1 din;
      end
    end
  end

  assign #1 dout =  (en)? mem[addr] : 32'hx;
endmodule

