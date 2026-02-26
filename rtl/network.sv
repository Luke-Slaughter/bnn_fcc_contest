//to do - add ram here


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


module bnn_network #(
    parameter int LAYER_ONE = 784;
    parameter int LAYER_TWO = 256;
    parameter int LAYER_THREE = 256;
    parameter int LAYER_FOUR = 10;
    parameter int RAM_WIDTH
    parameter int THRESHOLD_DATA_WIDTH
    
)(

    input logic clk, 
    input logic rst, 
    input logic start,
    input logic stop, 
    input logic is_hidden,

    input logic[LAYER_ONE-1 : 0] layerOneWeights,
    input logic[LAYER_TWO-1 : 0] layerTwoWeights,
    input logic[LAYER_THREE-1 : 0] layerThreeWeights,
    input logic[LAYER_FOUR-1 : 0] layerFourWeights,

    input logic[LAYER_ONE-1 : 0] layerOneThreshold,
    input logic[LAYER_TWO-1 : 0] layerTwoThreshold,
    input logic[LAYER_THREE-1 : 0] layerThreeThreshold,
    input logic[LAYER_FOUR-1 : 0] layerFourThreshold

    output logic[LAYER_FOUR-1 : 0] finalOutput

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



    generate 

        for(i = 0; i < LAYER_ONE-1; i++) begin : layer1
            np_1 #(
                .RAM_WIDTH(RAM_WIDTH),
                .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
            )neueronProc(
                .start(start),
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
                .start(start),
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
                .start(start),
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

    generate 
        for(i = 0; i < LAYER_FOUR-1; i++) begin : layer4
            np_1 #(
                .RAM_WIDTH(RAM_WIDTH),
                .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
            )neueronProc(
                .start(start),
                .stop(stop),
                .is_hidden(is_hidden),
                .rst(rst),
                .clk(clk),
                .threshold(layerFourThreshold[i]),
                .weights(layerFourWeights[i]),
                .data_in(layerThreeOut),
                .done(layerFourDone),
                .data_out(layerFourOut)
            )
        end
    endgenerate

    finalOutput <= layerFourOut;
    
endmodule
