`timescale 1ns/1ns

module uart_rx_tb ();

localparam ClOCKPERIOD = 50; // 20 MHz clock

logic rst_i, tick_i, ready_o, data_valid_o;
logic bit_i = 1'b1;
logic clk_i = 1'b0;
logic [7:0] data_o;
logic [4:0] baud_div_counter = 5'd0;
logic [3:0] counter_16 = 4'd0;

always #(ClOCKPERIOD/2) clk_i = !clk_i; 

initial begin
    rst_i = 1'b0;
    #(21*ClOCKPERIOD);
    rst_i = 1'b1;
end

// Test Cases

always_ff @( posedge clk_i ) begin 
    if (rst_i) begin
        baud_div_counter <= baud_div_counter + 'd1;
        counter_16 <= (tick_i == 1'b1) ? (counter_16 != 'd15 ? counter_16 +'d1 : 'd0) : counter_16;
    end
end
assign tick_i = (baud_div_counter == 'd30);

initial begin
    // test case - START B0  B1  B2  B3  B4  B5  B6  B7  STOP
    //               0   1   0   1   1   0   0   1   0    1 
    wait(rst_i);
    @(posedge clk_i);
    // START
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b0;
    #(ClOCKPERIOD);
    // 1
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b1;
    #(ClOCKPERIOD);
    // 2
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b0;
    #(ClOCKPERIOD);
    // 3
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b1;
    #(ClOCKPERIOD);
    // 4
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b1;
    #(ClOCKPERIOD);
    // 5
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b0;
    #(ClOCKPERIOD);
    // 6
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b0;
    #(ClOCKPERIOD);
    // 7
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b1;
    #(ClOCKPERIOD);
    // 8
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b0;
    #(ClOCKPERIOD);
    // STOP
    wait(counter_16 == 'd15 && tick_i == 1'b1);
    @(posedge clk_i);
    bit_i = 1'b1;
    #(ClOCKPERIOD);

end

// DUT

uart_rx uart_rx_i (
    .clk_i,
    .rst_i,
    .bit_i,
    .tick_i,
    .data_valid_o,
    .data_o
);

initial begin
    #(10000*ClOCKPERIOD);
    $finish;
end

initial begin
    $dumpfile("./temp/uart_rx.vcd");
    $dumpvars(0, uart_rx_tb);
end

endmodule