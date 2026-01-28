module np_1 #(
    parameter int RAM_WIDTH,
    parameter int THRESHOLD_DATA_WIDTH
) 
(
    input logic start,
    input logic stop,
    input logic is_hidden, //think about 
    input logic rst,
    input logic clk,
    
    input logic [THRESHOLD_DATA_WIDTH-1:0] threshold,
    input logic [RAM_WIDTH-1:0] weights,
    input logic [RAM_WIDTH-1:0] data_in,

    output logic done,
    output logic data_out
);

    typedef enum logic [2:0] {
        IDLE,
        CHECKSTOP,     
        XNOR_OP,  
        POPCOUNT_OP,     
        THRESHOLD_OP,
        OUTPUT  
    } state_t;

    state_t current_state, next_state;
    logic [RAM_WIDTH-1:0] after_xnor;
    logic [RAM_WIDTH-1:0] sum;

    always_ff @(posedge clk or posedge rst) begin
        
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        //set everything to 0/hold
        next_state = current_state;

        case(current_state)
            IDLE: begin
                if(start) begin
                    next_state = CHECKSTOP;
                end 
            end
            CHECKSTOP: begin
                if(stop) begin
                    next_state = THRESHOLD_OP;
                end else begin
                    next_state = XNOR_OP;
                end
            end
            XNOR_OP: begin
                after_xnor = weights ~^ data_in;
                next_state = POPCOUNT_OP;
            end
            POPCOUNT_OP: begin
                sum = $countones(after_xnor) + sum;
                next_state = CHECKSTOP;
            end
            THRESHOLD_OP: begin
                if(sum > 128)begin
                    data_out = 1;
                end else begin
                    data_out = 0;
                end
                next_state = OUTPUT;
            end
            OUTPUT: begin
                next_state = IDLE;
            end
        endcase
    end
endmodule