module layer#(
    parameter NEURONS_PER_NP = 16,
    parameter CALC_LAYERS = 3,
    parameter TOTAL_LAYERS = 4,
    parameter DATA_SIZE = 64,
    parameter INPUT_LAYER_SIZE = 784,
    parameter CURRENT_LAYER_SIZE = 256,
    parameter ADDRESS_WIDTH = 16,
    parameter LAYER_NP = CURRENT_LAYER_SIZE/NEURONS_PER_NP
)(
    input logic clk,
    input logic rst,
    input logic start,
    //previous input data
    input logic input_array [INPUT_LAYER_SIZE-1 :0],
    //weight bram
    output logic [$clog2(NEURONS_PER_NP)-1 :0] weight_addr [LAYER_NP], //inputs have to be layer brams and individual np bram have to be fed into generate statements 
    input logic [INPUT_LAYER_SIZE-1 :0] weight_data [LAYER_NP],
    //threshold bram
    output logic [$clog2(NEURONS_PER_NP)-1 :0] thres_addr [LAYER_NP],
    input logic [DATA_SIZE-1 :0] thres_data [LAYER_NP],
    //output signals
    output logic [NEURONS_PER_NP-1 :0] np_outputs [LAYER_NP],
    output logic done
);

    genvar i;
    typedef enum logic [2:0] {
            IDLE,
            WAIT,
            STATE_ONE,
            STATE_TWO,
            STATE_THREE
    } state_t;

    state_t current_state;
    logic [LAYER_NP-1 : 0] np_done_out;

    generate 
        for(i = 0; i < LAYER_NP;i++) begin
            np#(
                .NEURONS_PER_NP(NEURONS_PER_NP),
                .CALC_LAYERS(CALC_LAYERS),
                .TOTAL_LAYERS(TOTAL_LAYERS),
                .DATA_SIZE(DATA_SIZE),
                .INPUT_LAYER_SIZE(INPUT_LAYER_SIZE),
                .CURRENT_LAYER_SIZE(CURRENT_LAYER_SIZE),
                .ADDRESS_WIDTH(ADDRESS_WIDTH)
            )(

                .clk(clk),
                .rst(rst),
                .start(start),
                .input_array(input_array),
                .weight_addr(weight_addr[i]),
                .weight_data(weight_data[i]),
                .thres_addr(thres_addr[i]),
                .thres_data(thres_data[i]),
                .np_output(np_output[i]),
                .done(np_done_out[i]);

            );
        end

    endgenerate



    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            done <= 1'b0;

        end else begin
            case(current_state)

            IDLE: begin
                current_state <= IDLE;
                done <= 1'b0;
                if (start) begin
                    current_state <= STATE_ONE;
                end;
            end

            STATE_ONE : begin
                current_state <= STATE_ONE;
                done <= 1'b0;
                if ($countones(np_done_out) == LAYER_NP) begin
                    done <= 1'b1;
                    current_state <= IDLE;
                end
            end
            endcase

        end

    end
        

endmodule