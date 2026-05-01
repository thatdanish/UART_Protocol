module uart_top_tb ();
    
localparam ClOCKPERIOD = 50; // 20 MHz clock

logic rst_i, tick_i, ready_o, data_valid_o;
logic [10:0] baud_div_i = 11'd130;
logic data_valid_i = 1'b0;
logic clk_i = 1'b0;
logic [7:0] data_i, data_o;


always #(ClOCKPERIOD/2) clk_i = !clk_i; 

initial begin
    rst_i = 1'b0;
    #(21*ClOCKPERIOD);
    rst_i = 1'b1;
end

// Test Cases

initial begin
    wait(rst_i == 1'b1);
    #(ClOCKPERIOD);
    
    wait(ready_o == 1'b1);
    #(ClOCKPERIOD);
    @(posedge clk_i);
    data_valid_i = 1'b1;
    data_i = 8'd88;
    #(ClOCKPERIOD);
    
    wait(ready_o == 1'b0);
    #(ClOCKPERIOD);
    @(posedge clk_i);
    data_valid_i = 1'b0;
    
    wait(ready_o == 1'b1);
    #(20*ClOCKPERIOD);
    @(posedge clk_i);
    data_valid_i = 1'b1;
    data_i = 8'd17;
    #(ClOCKPERIOD);
    
    wait(ready_o == 1'b0);
    #(ClOCKPERIOD);
    @(posedge clk_i);
    data_valid_i = 1'b0;
end

// DUT

uart_top uart_top_i (
    .clk_i,
    .rst_i,
    .baud_div_i,
    .data_i,
    .data_valid_i,
    .ready_o,
    .data_o,
    .data_valid_o
);

initial begin
    #(50000*ClOCKPERIOD);
    $finish;
end

initial begin
    $dumpfile("./temp/uart_top.vcd");
    $dumpvars(0, uart_top_tb);
end


endmodule