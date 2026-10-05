`timescale 1ns / 1ps

module tb_top_memory_wrapper;

    reg clk;
    initial clk = 1'b0;
    always #5 clk <= ~clk;
    reg resetn;
    reg start;
    wire done;
    reg enb;
    reg [7:0] addrb, addrb_buf;
    wire [15:0] doutb;
    reg [15:0] answer_mem [0:255];
    
    initial begin
        $display("Welcom EE3551_Practice5_2!");
        resetn <= 1'b1;
        start <= 1'b0;
        enb <= 1'b0;
        addrb <= 8'd0;
        addrb_buf <= 8'd0;
        
        #302
        resetn <= 1'b0;
        #50
        resetn <= 1'b1;
        #50
        start <= 1'b1;
        #10
        start <= 1'b0;
        
        @(posedge done) begin
            $display("DUT Finishs Operation!");
            #10
            compare_memory();
            #10
            $finish();
        end
    end

    initial begin
      #300000
        $display("Error: Hit safety net @ %8dns", $time);
        $finish();
    end
    
    integer i;
    task compare_memory;
        begin
            $readmemh("D:/xilinix/BRAM_IP/answer_memory.hex", answer_mem);
            enb <= 1'b1;
            for(i=0; i<257; i=i+1) begin
                addrb <= i;
                addrb_buf <= addrb; #10
                if(i > 0) begin
                    if(answer_mem[addrb_buf] != doutb) begin
                        $display("Error: memory comparison failed @ %8dns", $time);
                        $display ("[%d] IIDEAL : %h DUT : %h", addrb_buf, answer_mem[addrb_buf],doutb );
                        $finish;
                    end
                end
            end
            $display("PASS: memory comparison succeed @ %8dns", $time);
        end
    endtask

    top_memory_wrapper Utop_memory_wrapper(
        .clk(clk),
        .resetn(resetn),

        .start(start),
        .done(done),

        .ext_enb(enb),
        .ext_addrb(addrb),
        .ext_doutb(doutb)
    );
    

endmodule
