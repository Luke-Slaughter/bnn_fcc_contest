module bram #(
    parameter DATA_WIDTH = 8;
    parameter ADDRESS_WIDTH = 16
)(

    input logic we,
    input logic re,
    input logic clk, 
    input logic rst,
    input logic[ADDRESS_WIDTH-1 :0] address,
    input logic[DATA_WIDTH-1 :0] data_in,
    output logic[DATA_WIDTH-1 :0] data_out
);
//Do we even need an address input since we are jsut storing data in one line?
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always_ff @(posedge clk or posedge rst) begin

        if(we) begin
            mem[address] <= data_in;
            data_out <= 'b0; 
        end

        if (re) begin
            data_out <=mem[address];
        end
    end
endmodule


        

