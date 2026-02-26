//this is single port - can only be read or written to

module sram
    #(parameter ADDR_WIDTH = 4, 
      parameter DATA_WIDTH = 8, 
      parameter DEPTH = 16      
    )
    (
        input wire                  clk,     
        input wire                  we,      
        input wire                  rd,      
        input wire [ADDR_WIDTH-1:0] addr,    
        input wire [DATA_WIDTH-1:0] data_in, 
        output reg [DATA_WIDTH-1:0] data_out 
    );

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we == 1'b1 && rd == 1'b0) begin
            mem[addr] <= data_in;
        end
    end

    always @(posedge clk) begin
        if (rd == 1'b1 && we == 1'b0) begin
            data_out <= mem[addr];
        end
    end
endmodule