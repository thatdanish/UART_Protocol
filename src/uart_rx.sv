`default_nettype none

module uart_rx (
    input clk_i,
    input rst_i,
    input bit_i,
    input tick_i,
    output logic [7:0] data_o,
    output logic data_valid_o
);
    
typedef enum bit[1:0] { IDLE, START, DATA, STOP } state_t;

logic [3:0] counter_16;
logic [2:0] counter_8;
bit middle_bit_indication, counter_16_indication, counter_8_indication;
logic [7:0] data;
state_t current_state, next_state;

assign middle_bit_indication = (counter_16 == 'd7);
assign counter_16_indication = (counter_16 == 'd15 && tick_i == 1'b1);
assign counter_8_indication = (counter_8 == 'd7 && tick_i == 1'b1);

always_ff @( posedge clk_i ) begin
    if (!rst_i) begin
        counter_16 <= 'd0;
        counter_8 <= 'd0;
    end else begin
        if (tick_i == 1'b1) begin
            counter_16 <= (current_state != IDLE || counter_16 != 'd15) ? counter_16 + 'd1 : 'd0; 
            counter_8 <= (current_state == DATA) ? (counter_16_indication == 1'b1 ? counter_8 + 'd1 : counter_8) : 'd0; 
        end
    end
end

always_ff @( posedge clk_i ) begin 
    if (!rst_i) data <= 'd0;
    else begin
        if (current_state == DATA && middle_bit_indication == 1'b1) begin
            data[7-counter_8] <= bit_i;
        end else data <= data;
    end
end

// Rx FSM

always_ff @( posedge clk_i ) begin 
    if(!rst_i) current_state <= IDLE;
    else begin
        current_state <= next_state;
    end
end

always_comb begin 
    next_state =  IDLE;
    case (current_state)
        IDLE : begin
            if (bit_i == 1'b0) next_state = START;
        end
        START : begin
            if (counter_16_indication == 1'b1) next_state = DATA;
            else next_state = START;
        end
        DATA : begin
            if (counter_8_indication == 1'b1 & counter_16_indication == 1'b1) next_state = STOP;
            else next_state = DATA;
        end
        STOP : begin
            if (counter_16_indication == 1'b1) next_state = IDLE;
            else next_state = STOP;
        end
        default: begin
            next_state =  IDLE;
        end
    endcase
end

always_comb begin 
    case (current_state)
        IDLE : begin
            data_o = 'd0;
            data_valid_o = 1'b0;
        end
        START : begin
            data_o = 'd0;
            data_valid_o = 1'b0;
        end
        DATA : begin
            data_o = 'd0;
            data_valid_o = 1'b0;
        end
        STOP : begin
            data_o = data;
            data_valid_o = 1'b1;
        end
        default: begin
            data_o = 'd0;
            data_valid_o = 1'b0;
        end
    endcase
end

endmodule