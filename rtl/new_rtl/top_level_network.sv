module top_level_network #(
    parameter NEURONS_PER_NP = 16,
    parameter CALC_LAYERS = 3,
    parameter TOTAL_LAYERS = 4,
    parameter DATA_SIZE = 32,
    parameter LAYER_ONE_SIZE = 784,
    parameter LAYER_TWO_SIZE = 256,
    parameter LAYER_THREE_SIZE = 256,
    parameter LAYER_FOUR_SIZE = 10,
    paramter ADDRESS_WIDTH = 16,
    parameter int TOPOLOGY[TOTAL_LAYERS] = '{0: 784, 1: 256, 2: 256, 3: 10, default: 0},  // 0: input, TOTAL_LAYERS-1: output
    parameter MAX_NP_PER_LAYER = (256+NEURONS_PER_NP-1)/NEURONS_PER_NP
)(
    input logic clk,
    input logic rst,
    input logic[LAYER_TWO_SIZE-1 : 0] inputImage,
    input logic inputImageRdy,
    input logic l2dataRdy,
    input logic l3dataRdy,
    input logic l4dataRdy,
    
    output logic final_out [LAYER_FOUR_SIZE-1 : 0],
    //Do I NEED COUNT OUT??????????????????????????/
    //        .count_out        (bnn_count_out),
    output logic final_out_valid;

);

    //2D array of wires that connect to all the WEIGHT BRAMs
    logic weight_we [CALC_LAYERS][MAX_NP_PER_LAYER];
    logic weight_re [CALC_LAYERS][];
    logic[DATA_SIZE] weight_addr [CALC_LAYERS][MAX_NP_PER_LAYER]; //CHANGE SIZE OF ADDRESSES
    logic[DATA_SIZE] weight_din [CALC_LAYERS][MAX_NP_PER_LAYER];
    logic[DATA_SIZE] weight_dout [CALC_LAYERS][MAX_NP_PER_LAYER];
    
    //2D array of wires that connect to all the THRESHOLD BRAMs
    logic thres_we [CALC_LAYERS][MAX_NP_PER_LAYER];
    logic thres_re [CALC_LAYERS][MAX_NP_PER_LAYER];
    logic[DATA_SIZE] thres_addr [CALC_LAYERS][MAX_NP_PER_LAYER]; //CHANGE SIZE OF ADDRESSES
    logic[DATA_SIZE] thres_din [CALC_LAYERS][MAX_NP_PER_LAYER];
    logic[DATA_SIZE] thres_dout [CALC_LAYERS][MAX_NP_PER_LAYER];

    logic layerTwoEnable, layerThreeEnable, layerFourEnable;
    logic layerTwoDone, layerThreeDone;

    logic [NEURONS_PER_NP-1 :0] layerTwoModuleOutput [LAYER_TWO_SIZE/NEURONS_PER_NP];
    logic [NEURONS_PER_NP-1 :0] layerThreeModuleOutput [LAYER_THREE_SIZE/NEURONS_PER_NP];
    logic [NEURONS_PER_NP-1 :0] layerFourModuleOutput [LAYER_FOUR_SIZE/NEURONS_PER_NP];

    // logic[LAYER_ONE_SIZE-1 : 0] layerOneIn;
    // logic[LAYER_ONE_SIZE-1 : 0] layerOneOut;
    logic[LAYER_TWO_SIZE-1 : 0] layerTwoIn;
    logic[LAYER_TWO_SIZE-1 : 0] layerTwoOut;
    logic[LAYER_THREE_SIZE-1 : 0] layerThreeOut;
    logic[LAYER_FOUR_SIZE-1 : 0] layerFourOut;

    assign layerTwoOut = {>>{layerTwoModuleOutput}};
    assign layerThreeOut = {>>{layerThreeModuleOutput}};
    assign layerFourOut = {>>{layerFourModuleOutput}};

    assign layerOneOut = { << logic [NEURONS_PER_NP-1:0] {np_outputs} };

    genvar i, j;
    genvar k = 2'b1;



    generate 
        for(i = 0; i < CALC_LAYERS; i++) begin
            for(j = 0 ; j < TOPOLOGY[k]/NEURONS_PER_NP; j++) begin

                bram #(
                    .DATA_WIDTH(DATA_SIZE);
                    .ADDRESS_WIDTH(NEURONS_PER_NP * TOPOLOGY[k-1]);
                ) weight_BRAM(
                    .we(weight_we[i][j]),
                    .re(weight_re[i][j]),
                    .clk(clk),
                    .rst(rst),
                    .address(weight_addr[i][j]),
                    .data_in(weight_din[i][j]),
                    .data_out(weight_dout[i][j])
                );

                bram #(
                    .DATA_WIDTH(DATA_SIZE);
                    .ADDRESS_WIDTH(NEURONS_PER_NP * TOPOLOGY[k-1]);
                ) threshold_BRAM(
                    .we(thres_we[i][j]),
                    .re(thres_re[i][j]),
                    .clk(clk),
                    .rst(rst),
                    .address(thres_addr[i][j]),
                    .data_in(thres_din[i][j]),
                    .data_out(thres_dout[i][j])
                );
            end
        end

    endgenerate


//LAYER ONE
    layer #(
        .NEURONS_PER_NP(NEURONS_PER_NP),
        .CALC_LAYERS(CALC_LAYERS),
        .TOTAL_LAYERS(TOTAL_LAYERS),
        .DATA_SIZE(DATA_SIZE),
        .INPUT_LAYER_SIZE(LAYER_ONE_SIZE);
        .CURRENT_LAYER_SIZE(LAYER_TWO_SIZE);
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        //.LAYER_NP()
    ) layer_two_declaration (

        .clk(clk),
        .rst(rst),
        .start(l2dataRdy && inputImageRdy),
        .input_array(inputImage),
        .weight_addr(weight_addr[0]),
        .weight_data(weight_dout[0]),
        .thres_addr(thres_addr[0]),
        .thres_data(thres_dout[0]),
        .np_output(layerTwoModuleOutput),
        .done(layerTwoDone)
    );

    layer #(
        .NEURONS_PER_NP(NEURONS_PER_NP),
        .CALC_LAYERS(CALC_LAYERS),
        .TOTAL_LAYERS(TOTAL_LAYERS),
        .DATA_SIZE(DATA_SIZE),
        .INPUT_LAYER_SIZE(LAYER_TWO_SIZE);
        .CURRENT_LAYER_SIZE(LAYER_THREE_SIZE);
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        //.LAYER_NP()
    ) layer_three_declaration (

        .clk(clk),
        .rst(rst),
        .start(layerTwoDone && l3dataRdy),
        .input_array(layerTwoOut),
        .weight_addr(weight_addr[1]),
        .weight_data(weight_dout[1]),
        .thres_addr(thres_addr[1]),
        .thres_data(thres_dout[1]),
        .np_output(layerThreeModuleOutput),
        .done(final_out_valid)
    );

    layer #(
        .NEURONS_PER_NP(NEURONS_PER_NP),
        .CALC_LAYERS(CALC_LAYERS),
        .TOTAL_LAYERS(TOTAL_LAYERS),
        .DATA_SIZE(DATA_SIZE),
        .INPUT_LAYER_SIZE(LAYER_THREE_SIZE);
        .CURRENT_LAYER_SIZE(LAYER_FOUR_SIZE);
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        //.LAYER_NP()
    ) layer_four_declaration (

        .clk(clk),
        .rst(rst),
        .start(layerThreeDone && l4dataRdy),
        .input_array(layerThreeOut),
        .weight_addr(weight_addr[2]),
        .weight_data(weight_dout[2]),
        .thres_addr(thres_addr[2]),
        .thres_data(thres_dout[2]),
        .np_output(layerFourModuleOutput),
        .done(layerFourDone)
    );

    typedef enum logic [2:0] {
            IDLE,
            STATE_ONE,
            STATE_TWO,
            STATE_THREE
    } state_t;

    state_t current_state;

    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         current_state <= IDLE;
    //         final_out <= '0;
    //         final_out_valid <= 1'b0;

    //         layerTwoEnable <= 1'b0;
    //         layerThreeEnable <= 1'b0;
    //         layerFourEnable <= 1'b0;
            
    //     end else begin
    //         case(current_state) 
    //             IDLE : begin
    //                 if(l2dataRdy)
    //                     current_state <= STATE_ONE;
    //                     layerTwoEnable <= 1'b1;
    //                 end else
    //                     current_state <= IDLE;
    //                 begin

    //             end

    //             STATE_ONE : begin
    //                 if(layerOneDone) begin
    //                     current_state <= STATE_TWO;
    //                 end

    //             end

    //         endcase

    //     end
    // end

endmodule



