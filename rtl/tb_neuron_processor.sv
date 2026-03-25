`timescale 1ns/1ps

module tb_np_1;

    // -------------------------
    // Parameters
    // -------------------------
    parameter RAM_WIDTH = 4;
    parameter THRESHOLD_DATA_WIDTH = 16;

    // -------------------------
    // Signals
    // -------------------------
    logic clk;
    logic rst;
    logic start;
    logic stop;
    logic is_hidden;

    logic [THRESHOLD_DATA_WIDTH-1:0] threshold;
    logic [RAM_WIDTH-1:0] weights;
    logic [RAM_WIDTH-1:0] data_in;

    logic done;
    logic data_out;

    // -------------------------
    // Instantiate the NP
    // -------------------------
    np_1 #(
        .RAM_WIDTH(RAM_WIDTH),
        .THRESHOLD_DATA_WIDTH(THRESHOLD_DATA_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stop(stop),
        .is_hidden(is_hidden),
        .threshold(threshold),
        .weights(weights),
        .data_in(data_in),
        .done(done),
        .data_out(data_out)
    );

    // -------------------------
    // Clock Generation
    // -------------------------
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // -------------------------
    // Test Procedure
    // -------------------------
    initial begin
        // Initialize signals
        rst = 1;
        start = 0;
        stop = 0;
        is_hidden = 0;
        weights = 0;
        data_in = 0;
        threshold = 16;

        #20;       // wait 2 clocks
        rst = 0;

        // -------------------------
        // Test 1: Simple pattern
        // -------------------------
        start = 1;
        weights = 4'b1000;  // example pattern
        data_in = 4'b0101;  // opposite pattern
        threshold = 2;

        #10;      // one clock
        start = 0;

        // Wait until NP asserts done
        wait(done == 1);
        $display("Test 1: data_out = %b, done = %b", data_out, done);

        // -------------------------
        // Test 2: Random weights and data
        // -------------------------

        $stop;
    end


endmodule