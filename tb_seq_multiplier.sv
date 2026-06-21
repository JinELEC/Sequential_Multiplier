`timescale 1ns / 1ps 

module tb_seq_multiplier;

parameter TB_N = 4;

logic              clk;
logic              n_rst;
logic              start;
logic [TB_N-1:0]   Min;
logic [TB_N-1:0]   Qin;
logic              ready;
logic [2*TB_N-1:0] AQ;


// Instantiation
seq_multiplier #(.N(TB_N)) m0 (.*);

initial clk = 1'b0; 
always #10 clk = ~clk; 

// reset
initial begin
    n_rst = '1;
    #2 n_rst = '0;
    #2 n_rst = '1;
end
  
initial begin
    start = '0;
    Min = '0;
    Qin = '0;
    #5 start = '1;
    Min = 3;
    Qin = 5;
    
    @(posedge ready); 
    
    #1;
    if (AQ == Min * Qin)
        $display("Test passed: at %t Min = %d, Qin = %d, AQ = %d", $time, Min, Qin, AQ);
    else
        $display("Test failed: at %t Min = %d, Qin = %d, AQ = %d", $time, Min, Qin, AQ);
end

initial begin
    $dumpfile("tb_seq_multiplier.vcd");
    $dumpvars(0, tb_seq_multiplier);    
    #1000;                          
    $finish;
end
  
endmodule