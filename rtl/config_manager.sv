/*

Description:
Basically all RAMS share the same address and the same data line

Inputs:
    input  logic                          config_valid,   //if its valid and should be kept - move counter here
    input  logic [  CONFIG_BUS_WIDTH-1:0] config_data,    //the actual data
    input  logic [CONFIG_BUS_WIDTH/8-1:0] config_keep,    //Which bytes in tdata are valid
    input  logic                          config_last,    //Marks the last beat of a packet

    input  logic                          clk
Outputs:
    output  logic [ADDR_WIDTH-1:0]        addr;
    output  logic [DATA_WIDTH-1:0]        data_in;
    output  logic [NUM_RAMS-1:0]          we;

Internal Signals:

FIFO:
    input               	rstn,               // Active low reset
                            clk,                // Clock
                            wr_en, 				// Write enable
                            rd_en, 				// Read enable
    input      [DWIDTH-1:0] din, 				// Data written into FIFO
    output reg [DWIDTH-1:0] dout, 				// Data read from FIFO
    output              	empty, 				// FIFO is empty when high
                            full 				// FIFO is full when high

*/

module config_manager #(
    parameter int NUM_RAMS  = 8
);


endmodule
