`default_nettype none

module uart_tx (
    input clk_i,
    input rst_i,
    input logic[7:0] data_i,
    input tick_i,
    input data_valid_i,
    output logic ready_o,
    output logic data_bit_o
);

typedef enum bit[1:0] { IDLE, START, DATA, STOP } state_t;

logic [3:0] counter_16;
logic [2:0] counter_8;
logic [7:0] data;

bit counter_16_indication;
bit counter_8_indication;
state_t current_state, next_state;

assign counter_16_indication = (counter_16 == 'd15 && tick_i);
assign counter_8_indication = (counter_8 == 'd7);

always_ff @(posedge clk_i) begin
    if (!rst_i) begin
        counter_16 <= '0;
        counter_8 <= '0;
        data <= '0;
        ready_o <= 1'b0;
    end else begin
        data <= (data_valid_i==1'b1) ? data_i : data; // store data
        ready_o <= (current_state == IDLE && !data_valid_i);
        if (current_state != IDLE) begin
            counter_16 <= (tick_i == 1'b1) ? ((counter_16 == 'd15) ? 'd0 : counter_16 + 'd1 ) : counter_16;
        end

        if (current_state == DATA) begin
            counter_8 <= (counter_16_indication == 1'b1) ? ((counter_8 == 'd7) ?   'd0 : counter_8 + 'd1) : counter_8; 
        end
    end
end

// Tx FSM

always_ff @(posedge clk_i) begin
    if (!rst_i) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin 
    next_state =  IDLE;
    case (current_state)
        IDLE : begin
            if (data_valid_i==1'b1) next_state = START;
        end 
        START : begin
            if (counter_16_indication == 1'b1) next_state = DATA;
            else next_state = START; 
        end 
        DATA : begin
            if (counter_8_indication == 1'b1 && counter_16_indication == 1'b1) next_state = STOP;
            else next_state =  DATA;
        end 
        STOP : begin
            if (counter_16_indication == 1'b1) next_state = IDLE;
            else next_state = STOP;
        end 
        default: begin
            next_state = IDLE;
        end
    endcase
end

always_comb begin 
    case (current_state)
        IDLE : data_bit_o = 1'b1;
        START : data_bit_o = 1'b0;
        DATA : data_bit_o = data[counter_8];
        STOP : data_bit_o = 1'b1;
        default: data_bit_o = 1'b1;
    endcase
end

endmodule