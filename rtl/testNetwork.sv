module np_1 #(
    parameter int RAM_WIDTH,
    parameter int THRESHOLD_DATA_WIDTH
) 
(
    input logic start,
    input logic stop,
    input logic is_hidden, 
    input logic rst,
    input logic clk,
    
    input logic [THRESHOLD_DATA_WIDTH-1:0] threshold,
    input logic [RAM_WIDTH-1:0] weights,
    input logic [RAM_WIDTH-1:0] data_in,

    output logic done,
    output logic data_out

);
endmodule


module test_bnn_network #(
    parameter int LAYER_ONE = 3;
    parameter int LAYER_TWO = 2;
    parameter int LAYER_THREE = 2;
    // parameter int LAYER_FOUR = 10;
    parameter int RAM_WIDTH
    parameter int THRESHOLD_DATA_WIDTH
    
)(

    input logic clk, 
    input logic rst, 
    input logic start,
    input logic stop, 
    input logic is_hidden,

    input logic[LAYER_ONE-1 : 0] bramLayerOneWeights,
    input logic[LAYER_TWO-1 : 0] bramLayerTwoWeights,
    input logic[LAYER_THREE-1 : 0] bramLayerThreeWeights,
    // input logic[LAYER_FOUR-1 : 0] layerFourWeights,

    input logic[LAYER_ONE-1 : 0] bramLayerOneThreshold,
    input logic[LAYER_TWO-1 : 0] bramLayerTwoThreshold,
    input logic[LAYER_THREE-1 : 0] bramLayerThreeThreshold,
    // input logic[LAYER_FOUR-1 : 0] layerFourThreshold

    output logic[LAYER_THREE-1 : 0] finalOutput

);
    logic[LAYER_ONE-1 : 0] layerOneIn;
    logic[LAYER_ONE-1 : 0] layerOneOut;
    logic[LAYER_TWO-1 : 0] layerTwoOut;
    logic[LAYER_THREE-1 : 0] layerThreeOut;
    logic[LAYER_FOUR-1 : 0] layerFourOut;

    logic[LAYER_ONE-1 : 0] layerOneWeights
    logic[LAYER_TWO-1 : 0] layerTwoWeights
    logic[LAYER_THREE-1 : 0] layerThreeWeights
    logic[LAYER_FOUR-1 : 0] layerFourWeights

    logic layerOneDone;
    logic layerTwoDone;
    logic layerThreeDone;
    logic layerFourDone;
    logic layer1Start, layer2Start, layer3Start.


    generate 

        for(i = 0; i < LAYER_ONE-1; i++) begin : layer1
            np_1 #(
                .RAM_WIDTH(RAM_WIDTH),
                .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
            )neueronProc(
                .start(layer1Start),
                .stop(stop),
                .is_hidden(is_hidden),
                .rst(rst),
                .clk(clk),
                .threshold(layerOneThreshold[i]),
                .weights(layerOneWeights[i]),
                .data_in(layerOneIn),
                .done(layerOneDone),
                .data_out(layerOneOut)
            )
        end
    endgenerate

    
    
    generate 
        for(i = 0; i < LAYER_TWO-1; i++) begin : layer2
            np_1 #(
                .RAM_WIDTH(RAM_WIDTH),
                .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
            )neueronProc(
                .start(layer2Start),
                .stop(stop),
                .is_hidden(is_hidden),
                .rst(rst),
                .clk(clk),
                .threshold(layerTwoThreshold[i]),
                .weights(layerTwoWeights[i]),
                .data_in(layerOneOut),
                .done(layerTwoDone),
                .data_out(layerTwoOut)
            )
        end
    endgenerate


    generate 
        for(i = 0; i < LAYER_THREE-1; i++) begin : layer3
            np_1 #(
                .RAM_WIDTH(RAM_WIDTH),
                .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
            )neueronProc(
                .start(layer3Start),
                .stop(stop),
                .is_hidden(is_hidden),
                .rst(rst),
                .clk(clk),
                .threshold(layerThreeThreshold[i]),
                .weights(layerThreeWeights[i]),
                .data_in(layerTwoOut),
                .done(layerThreeDone),
                .data_out(layerThreeOut)
            )
        end
    endgenerate

    // generate 
    //     for(i = 0; i < LAYER_FOUR-1; i++) begin : layer4
    //         np_1 #(
    //             .RAM_WIDTH(RAM_WIDTH),
    //             .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
    //         )neueronProc(
    //             .start(start),
    //             .stop(stop),
    //             .is_hidden(is_hidden),
    //             .rst(rst),
    //             .clk(clk),
    //             .threshold(layerFourThreshold[i]),
    //             .weights(layerFourWeights[i]),
    //             .data_in(layerThreeOut),
    //             .done(layerFourDone),
    //             .data_out(layerFourOut)
    //         )
    //     end
    // endgenerate

    finalOutput <= layerThreeOut;
    
endmodule
