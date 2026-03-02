// module np_1 #(
//     parameter int RAM_WIDTH = 256,
//     parameter int THRESHOLD_DATA_WIDTH = 16
// ) 
// (
//     input logic start,
//     input logic stop,
//     input logic is_hidden, //think about 
//     input logic rst,
//     input logic clk,
    
//     input logic [THRESHOLD_DATA_WIDTH-1:0] threshold,
//     input logic [RAM_WIDTH-1:0] weights,
//     input logic [RAM_WIDTH-1:0] data_in,

//     output logic done,
//     output logic data_out
// );

//     typedef enum logic [2:0] {
//         IDLE,
//         CHECKSTOP,     
//         XNOR_OP,  
//         POPCOUNT_OP,     
//         THRESHOLD_OP,
//         OUTPUT  
//     } state_t;

//     state_t current_state;

//     logic [RAM_WIDTH-1:0] after_xnor;
//     logic [$clog2(RAM_WIDTH+1)-1:0] sum;

//     always_ff @(posedge clk or posedge rst) begin
        
//         if (rst) begin
//             current_state <= IDLE;
//             sum <= 0;
//             data_out <= 0;
//             done <= 0;

//         end else begin
//             case(current_state)
//                 IDLE: begin
//                     if(start) begin
//                         current_state <= XNOR_OP;
//                     end else begin
//                         current_state <= IDLE;
//                     end
//                 end
//                 XNOR_OP: begin
//                     after_xnor <= weights ~^ data_in;
//                     current_state <= POPCOUNT_OP;
//                 end
//                 POPCOUNT_OP: begin
//                     sum <= $countones(after_xnor) + sum;
//                     current_state <= THRESHOLD_OP;
//                 end
//                 THRESHOLD_OP: begin
//                     if(sum > threshold)begin //DO WE NEED >= or just >
//                         data_out <= 1;
//                     end else begin
//                         data_out <= 0;
//                     end
//                     current_state = OUTPUT;
//                 end
//                 OUTPUT: begin
//                     done <= 1;
//                     current_state = IDLE;
//                 end
//             endcase
//         end 
//     end
// endmodule




module np_1 #(
    parameter int RAM_WIDTH = 256,
    parameter int THRESHOLD_DATA_WIDTH = 16
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
    logic [$clog2(RAM_WIDTH+1)-1:0] sum;

    always_ff @(posedge clk or posedge rst) begin
        
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        case(current_state)
            IDLE: begin
                done = 0;
                sum = 0;
                if(start) begin
                    next_state = XNOR_OP;
                end 
            end

            XNOR_OP: begin
                after_xnor = weights ~^ data_in;
                next_state = POPCOUNT_OP;
            end
            POPCOUNT_OP: begin
                sum = $countones(after_xnor);
                next_state = THRESHOLD_OP;
            end
            THRESHOLD_OP: begin
                if(sum > threshold)begin
                    data_out = 1;
                end else begin
                    data_out = 0;
                end
                next_state = OUTPUT;

            end
            OUTPUT: begin
                done = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule