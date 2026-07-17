/* FROM TEST BENCH CODE:

for (int i = 0; i < config_bus_data_stream.size(); i++) begin

            // Simulate gaps on configuration bus.
            while (!chance(
                CONFIG_VALID_PROBABILITY
            )) begin
                config_in.tvalid <= 1'b0;
                @(posedge clk iff config_in.tready);
            end

            config_in.tvalid <= 1'b1;
            config_in.tdata  <= config_bus_data_stream[i];
            config_in.tlast  <= i == config_bus_data_stream.size() - 1;
            config_in.tkeep  <= config_bus_keep_stream[i];
            @(posedge clk iff config_in.tready);
        end


*/


// CONFIG HEADER:

// Configuration header (first 128 bits of message stream)
//
// Bit field   Name             Width   Description
// [7:0]       msg_type         8       0 = Weights, 1 = Thresholds
// [15:8]      layer_id         8       Index of the current layer
// [31:16]     layer_inputs     16      Exact fan-in (e.g., 784) of layer_id
//                                      (ignore when msg_type = 1)
// [47:32]     num_neurons      16      Total number of neurons in layer_id
// [63:48]     bytes_per_neuron 16      Number of bytes in the payload per neuron
// [95:64]     total_bytes      32      Total payload bytes for the message
// [127:96]    reserved         32      Reserved for future use

module config_manager #(
        parameter int BUS_WIDTH = 64,        
        parameter int LAYERS = 3,        
        parameter int PARALLEL_INPUTS,
        parameter int PARALLEL_NEURONS,
        parameter DATA_SIZE = 64, //since its 64 bits into config manager at a time
        parameter NEURONS_PER_NP = 16,
        parameter CALC_LAYERS = 3
    )(
        input  logic                          clk,
        input  logic                          rst,
        input  logic                          config_valid,   //if its valid and should be kept - check this
        input  logic [BUS_WIDTH-1:0] config_data,    //the actual data
        input  logic [BUS_WIDTH/8-1:0] config_keep,    //Which bytes in tdata are valid
        input  logic                          config_last,    //Marks the last beat of the config stream
        input  logic start, //when the overall controller says to start
        output logic                          config_ready, //important to interface with the data in, send in to get next data
        output logic                          done, //when done with config manager assert
        
        output logic weight_we [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)],
        output logic[$clog2(NEURONS_PER_NP)-1:0] weight_addr [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)], //CHANGE SIZE OF ADDRESSES
        output logic[DATA_SIZE-1:0] weight_din [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)],
         
        //2D array of wires that connect to all the THRESHOLD BRAMs
        output logic thres_we [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)],
        output logic[$clog2(NEURONS_PER_NP)-1:0] thres_addr [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)], //CHANGE SIZE OF ADDRESSES
        output logic[DATA_SIZE-1:0] thres_din [CALC_LAYERS][((256+NEURONS_PER_NP-1)/NEURONS_PER_NP)]
    );

    logic[31:0] np_id;
    logic[31:0] addr;

    logic [31:0] payload_byte_index;
    logic [31:0] neuron_id;
    logic [31:0] byte_in_neuron;

    logic header_half;
    logic [127:0] header_reg;

    typedef enum logic [3:0] {
    IDLE,
    READ_HEADER,
    PARSE_HEADER,
    WRITE_BRAM,
    DONE
    } state_t;

    state_t state;  

    logic [31:0] bytes_remaining;

    logic [7:0] msg_type;
    logic [7:0] layer_id;
    logic [15:0] num_neurons;
    logic [15:0] bytes_per_neuron;

    logic [31:0] neuron_counter;

    always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        config_ready <= 1;
        header_half <= 0;
        bytes_remaining <= 0;
        neuron_counter <= 0;
        done <= 0;
        payload_byte_index <= 0;
    end
    else begin

        //disable everything -- how much fanout is this??
        for (int l = 0; l < CALC_LAYERS; l++) begin
            for (int n = 0; n < ((256+NEURONS_PER_NP-1)/NEURONS_PER_NP); n++) begin
                weight_we[l][n] <= 0;
                thres_we[l][n]  <= 0;
            end
        end

        case (state)
        IDLE: begin
            if(start) state <= READ_HEADER;
        end
        READ_HEADER: begin
            if(config_valid && config_ready) begin
                if(!header_half) begin
                    header_reg[63:0] <= config_data;
                    header_half <= 1;
                end
                else begin
                    header_reg[127:64] <= config_data;
                    header_half <= 0;
                    state <= PARSE_HEADER;
                end
            end
        end
        PARSE_HEADER: begin
            msg_type         <= header_reg[7:0];
            layer_id         <= header_reg[15:8];
            num_neurons      <= header_reg[47:32];
            bytes_per_neuron <= header_reg[63:48];
            bytes_remaining  <= header_reg[95:64];

            neuron_counter <= 0;
            state <= WRITE_BRAM;
        end
        WRITE_BRAM: begin
            if(config_valid && config_ready) begin
                //keep same weight_we and same 
                    neuron_id      = payload_byte_index / bytes_per_neuron;
                    byte_in_neuron = payload_byte_index % bytes_per_neuron;

                    np_id = neuron_id / NEURONS_PER_NP;
                    addr  = neuron_id % NEURONS_PER_NP;

                    if(msg_type == 0) begin
                        weight_we[layer_id][np_id]   <= 1;
                        weight_addr[layer_id][np_id] <= addr;
                        weight_din[layer_id][np_id]  <= config_data;
                    end
                    else begin
                        thres_we[layer_id][np_id]   <= 1;
                        thres_addr[layer_id][np_id] <= addr;
                        thres_din[layer_id][np_id]  <= config_data;
                    end
                payload_byte_index <= payload_byte_index + 1;
                //
                bytes_remaining <= bytes_remaining - (BUS_WIDTH/8);

                if(config_last)
                    state <= DONE;
                else if(bytes_remaining <= (BUS_WIDTH/8))
                    state <= READ_HEADER;
            end
        end
        DONE: begin
            done <= 1;
        end
        endcase
    end
end
endmodule