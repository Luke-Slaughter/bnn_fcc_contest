module top_level_network #(
    parameter NEURONS_PER_NP = 16,
    parameter CALC_LAYERS = 3,
    parameter TOTAL_LAYERS = 4,
    parameter DATA_SIZE = 32,
    parameter LAYER_ONE_SIZE = 784,
    parameter LAYER_ONE_SIZE = 256,
    parameter LAYER_ONE_SIZE = 256,
    parameter LAYER_ONE_SIZE = 10
    parameter int TOPOLOGY[TOTAL_LAYERS] = '{0: 784, 1: 256, 2: 256, 3: 10, default: 0},  // 0: input, TOTAL_LAYERS-1: output

)(
    input logic clk,
    input logic rst
);

    //2D array of wires that connect to all the WEIGHT BRAMs
    logic weight_we [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    logic weight_re [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    logic[DATA_SIZE] weight_addr [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)]; //CHANGE SIZE OF ADDRESSES
    logic[DATA_SIZE] weight_din [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    logic[DATA_SIZE] weight_dout [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    
    //2D array of wires that connect to all the THRESHOLD BRAMs
    logic thres_we [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    logic thres_re [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    logic[DATA_SIZE] thres_addr [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)]; //CHANGE SIZE OF ADDRESSES
    logic[DATA_SIZE] thres_din [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];
    logic[DATA_SIZE] thres_dout [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)];

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


endmodule


