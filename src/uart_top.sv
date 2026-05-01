`default_nettype  none

module uart_top(
    input clk_i,
    input rst_i,
    // Baud Rate Gen
    input logic [10:0] baud_div_i,
    // Tx
    input logic [7:0] data_i,
    input data_valid_i,
    output ready_o,
    // Rx
    output logic [7:0] data_o,
    output data_valid_o
);


logic tick, data_bit_to_rx;

uart_baud_gen uart_baud_gen_i (
    .clk_i,
    .rst_i,
    .baud_div_i,
    .tick_o(tick)
);

uart_tx uart_tx (
    .clk_i,
    .rst_i,
    .data_i,
    .data_valid_i,
    .tick_i(tick),
    .ready_o,
    .data_bit_o(data_bit_to_rx)
);

uart_rx uart_rx (
    .clk_i,
    .rst_i,
    .tick_i(tick),
    .bit_i(data_bit_to_rx),
    .data_o,
    .data_valid_o
);

endmodule