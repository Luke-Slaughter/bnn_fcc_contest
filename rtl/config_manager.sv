/*

To do:
Figure out config_keep -> byte masking
Figure out the header information

Description:
- Put weights and thresholds going in, to each Neuron Processor which handles several neurons

Notes:
- Basically all RAMS share the same address and the same data line
- Use the config_last signal to demux to the next ram, increment current ram by 1
- Lets not actually use FIFO for now and assume there's not pipelining involved
*/

module config_manager #(
    parameter int CONFIG_BUS_WIDTH = 64,
    parameter int DATA_WIDTH       = 64,
    parameter int ADDR_WIDTH       = 10,
    parameter int NUM_RAMS  = 8,
    parameter int NUM_NEURON_PER_NP = 80 //change later
)
(
    input  logic                          config_valid,   //if its valid and should be kept - move counter here
    input  logic [  CONFIG_BUS_WIDTH-1:0] config_data,    //the actual data
    input  logic [CONFIG_BUS_WIDTH/8-1:0] config_keep,    //Which bytes in tdata are valid
    input  logic                          config_last,    //Marks the last beat of a packet
    input  logic                          clk,
    input  logic                          rst,
    output logic [ADDR_WIDTH-1:0]         addr, //RAM
    output logic [DATA_WIDTH-1:0]         data_in, //RAM
    output logic [NUM_RAMS-1:0]           we, //x we for x num of RAMS
    output logic                          config_ready //important to interface with the data in
    output logic                          done; //when done wiith config manager wait there
);

//internal signals
logic [$clog2(NUM_RAMS)-1:0] current_ram;
logic [$clog2(NUM_NEURON_PER_NP)-1:0] current_neuron;
logic [ADDR_WIDTH-1:0] addr_counter;
logic transfer;

//assigns
assign config_ready = !done;
assign transfer = config_valid && config_ready;
assign addr = addr_counter;
assign data_in = config_data;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        current_ram     <= 0;
        current_neuron  <= 0;
        addr_counter    <= 0;
        done            <= 0;
    end
    else if (transfer) begin

        // Write data and inc address
        addr_counter <= addr_counter + 1;

        // End of neuron packet
        if (config_last) begin
            addr_counter <= 0;

            if (current_neuron == NUM_NEURON_PER_NP-1) begin
                current_neuron <= 0;
                
                if (current_ram == NUM_RAMS-1) begin
                    done <= 1'b1;
                end
                else begin
                    current_ram <= current_ram + 1;
                end
            end
            else begin
                current_neuron <= current_neuron + 1;
            end
        end
    end
end

always_comb begin
    we = '0;
    if(transfer) we[current_ram] = 1'b1;
end

endmodule
