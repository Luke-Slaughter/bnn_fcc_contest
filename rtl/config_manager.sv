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
        parameter int BUS_WIDTH = 64,        
        parameter int LAYERS = 3,        
        parameter int PARALLEL_INPUTS,
        parameter int PARALLEL_NEURONS,
        parameter DATA_SIZE = 32,
        parameter NEURONS_PER_NP = 16,
        parameter CALC_LAYERS = 3
    )(
        input  logic                          clk,
        input  logic                          rst,
        input  logic                          config_valid,   //if its valid and should be kept - move counter here
        input  logic [BUS_WIDTH-1:0] config_data,    //the actual data
        input  logic [BUS_WIDTH/8-1:0] config_keep,    //Which bytes in tdata are valid
        input  logic                          config_last,    //Marks the last beat of a packet
        output logic                          config_ready, //important to interface with the data in
        output logic                          done, //when done wiith config manager wait there
        
        output logic weight_we [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)],
        output logic[DATA_SIZE] weight_addr [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)], //CHANGE SIZE OF ADDRESSES
        output logic[DATA_SIZE] weight_din [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)],
         
        //2D array of wires that connect to all the THRESHOLD BRAMs
        output logic thres_we [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)],
        output logic[DATA_SIZE] thres_addr [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)], //CHANGE SIZE OF ADDRESSES
        output logic[DATA_SIZE] thres_din [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)]
    );

    logic np_id ;

    typedef enum logic [3:0] {
    IDLE,
    READ_HEADER,
    PARSE_HEADER,
    WRITE_BRAM,
    DONE
    } state_t;

    state_t state;  

    logic [127:0] header;
    logic [31:0] bytes_remaining;

    logic [7:0] msg_type;
    logic [7:0] layer_id;
    logic [15:0] num_neurons;
    logic [15:0] bytes_per_neuron;

    logic [31:0] neuron_counter;

    always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= READ_HEADER;
        config_ready <= 1;
        neuron_counter <= 0;
    end
    else begin
        case (state)
        READ_HEADER: begin
            if (config_valid && config_ready) begin
                header <= config_data;
                state <= PARSE_HEADER;
            end
        end
        PARSE_HEADER: begin
            msg_type         <= header[7:0];
            layer_id         <= header[15:8];
            num_neurons      <= header[47:32];
            bytes_per_neuron <= header[63:48];
            bytes_remaining  <= header[95:64];

            neuron_counter <= 0;
            state <= WRITE_BRAM;
        end
        WRITE_BRAM: begin               
            
        end
        endcase
    end
end
endmodule



//OLD VERSION

/*

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
    output logic                          config_ready, //important to interface with the data in
    output logic                          done //when done wiith config manager wait there
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
*/