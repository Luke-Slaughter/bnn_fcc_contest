module bram #(
    parameter DATA_WIDTH = 784,
    parameter ADDRESS_WIDTH = 8,
    parameter DATA_OUT_WIDTH = 784,
    parameter NEURONS_PER_NP = 2
)(

    input logic we,
    input logic clk, 
    input logic rst,
    input logic[$clog2(NEURONS_PER_NP)-1:0] address,
    input logic[DATA_WIDTH-1 :0] data_in,
    output logic[DATA_OUT_WIDTH-1 :0] data_out
);
    logic [DATA_OUT_WIDTH-1:0] mem [0:NEURONS_PER_NP-1];

    always_ff @(posedge clk) begin

        if(we) begin
            mem[address] <= data_in;
            data_out <= 'b0; 
        end else begin
            data_out <=mem[address];
        end 
    end
endmodule


        

