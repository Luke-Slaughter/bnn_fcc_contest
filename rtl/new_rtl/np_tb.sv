`timescale 1ns/1ps

module np_tb;

    // =========================
    // PARAMETERS
    // =========================
    parameter NEURONS_PER_NP   = 2;
    parameter DATA_SIZE        = 8;
    parameter INPUT_LAYER_SIZE = 4;
    parameter ADDRESS_WIDTH    = 8;

    // =========================
    // SIGNALS
    // =========================
    logic clk, rst, start;

    logic [INPUT_LAYER_SIZE-1:0] input_array;

    logic [$clog2(NEURONS_PER_NP)-1:0] weight_addr;
    logic [INPUT_LAYER_SIZE-1:0]         weight_data;

    logic [$clog2(NEURONS_PER_NP)-1:0]   thres_addr;
    logic [DATA_SIZE-1:0]                thres_data;

    logic [NEURONS_PER_NP-1:0] np_output;
    logic done;

    // BRAM control
    logic weight_we, thres_we;
    logic [INPUT_LAYER_SIZE-1:0] weight_din;
    logic [DATA_SIZE-1 : 0] thres_din;

    // =========================
    // DUT: NP
    // =========================
    np #(
        .NEURONS_PER_NP(NEURONS_PER_NP),
        .DATA_SIZE(DATA_SIZE),
        .INPUT_LAYER_SIZE(INPUT_LAYER_SIZE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .input_array(input_array),

        .weight_addr(weight_addr),
        .weight_data(weight_data),

        .thres_addr(thres_addr),
        .thres_data(thres_data),

        .np_output(np_output),
        .done(done)
    );

    // =========================
    // WEIGHT BRAM
    // =========================
    bram #(
        .DATA_WIDTH(DATA_SIZE),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_OUT_WIDTH(INPUT_LAYER_SIZE)
    ) weight_bram (
        .we(weight_we),
        .clk(clk),
        .rst(rst),
        .address(weight_addr),
        .data_in(weight_din),
        .data_out(weight_data)
    );

    // =========================
    // THRESHOLD BRAM
    // =========================
    bram #(
        .DATA_WIDTH(DATA_SIZE),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_OUT_WIDTH(DATA_SIZE)
    ) thres_bram (
        .we(thres_we),
        .clk(clk),
        .rst(rst),
        .address(thres_addr),
        .data_in(thres_din),
        .data_out(thres_data)
    );

    // =========================
    // CLOCK
    // =========================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================
    // TASKS TO WRITE BRAM
    // =========================
    task write_weight(input int addr, input logic [INPUT_LAYER_SIZE-1:0] data);
    begin
        @(posedge clk);
        weight_we   = 1;
        weight_addr = addr;
        weight_din  = data;

        @(posedge clk);
        weight_we   = 0;
    end
    endtask

    task write_thres(input int addr, input logic [63:0] data);
    begin
        @(posedge clk);
        thres_we   = 1;
        thres_addr = addr;
        thres_din  = data;

        @(posedge clk);
        thres_we   = 0;
    end
    endtask

    // =========================
    // TEST SEQUENCE
    // =========================
    initial begin
        integer i;

        // Init
        rst = 1;
        start = 0;
        weight_we = 0;
        thres_we  = 0;

        // Input = all 1s
        input_array = INPUT_LAYER_SIZE'(4'b1010);
        #20;
        rst = 0;

        // =========================
        // LOAD WEIGHTS
        // =========================
        // Only lower 64 bits will be valid
            write_weight(0, INPUT_LAYER_SIZE'(4'b1010));
            write_weight(1, INPUT_LAYER_SIZE'(3'b111));


        // =========================
        // LOAD THRESHOLDS
        // =========================
            write_thres(0, DATA_SIZE'(5'b00011)); // threshold < 64 → expect 1
            write_thres(1, DATA_SIZE'(2'b10));

        // =========================
        // START NP
        // =========================
        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        // =========================
        // WAIT FOR DONE
        // =========================
        wait(done);

        #10;

        $display("=================================");
        $display("NP OUTPUT: %b", np_output);
        $display("=================================");

        // =========================
        // CHECK RESULTS
        // =========================
        for (i = 0; i < NEURONS_PER_NP; i++) begin
            if (np_output[i] !== 1'b1)
                $display("ERROR: neuron %0d FAILED", i);
            else
                $display("Neuron %0d OK", i);
        end

        #20;
        $finish;
    end

endmodule
