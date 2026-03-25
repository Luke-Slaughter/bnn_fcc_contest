module np #(
    parameter NEURONS_PER_NP = 16,
    parameter CALC_LAYERS = 3,
    parameter TOTAL_LAYERS = 4,
    parameter DATA_SIZE = 64,
    parameter INPUT_LAYER_SIZE = 784,
    parameter CURRENT_LAYER_SIZE = 256,
    parameter ADDRESS_WIDTH = 16
)(
    input logic clk,
    input logic rst,
    input logic start,
    //previous input data
    input logic input_array [INPUT_LAYER_SIZE-1 :0],
    //weight bram
    output logic [$clog2(NEURONS_PER_NP)-1 :0] weight_addr,
    input logic [INPUT_LAYER_SIZE-1 :0] weight_data,
    //threshold bram
    output logic [$clog2(NEURONS_PER_NP)-1 :0] thres_addr,
    input logic [DATA_SIZE-1 :0] thres_data,
    //output signals
    output logic [NEURONS_PER_NP-1 :0] np_output,
    output logic done

);

typedef enum logic [2:0] {
        IDLE,
        WAIT,
        STATE_ONE,
        STATE_TWO,
        STATE_THREE
    } state_t;

    state_t current_state;
    logic [$clog2(NEURONS_PER_NP)-1 :0] activeNeuronIndex;
    logic [NEURONS_PER_NP-1 : 0] neuronOutputs;
 
    logic [$clog2(NEURONS_PER_NP)-1 :0] nextNeuronIndex;
    logic [$clog2(NEURONS_PER_NP)-1 :0] nextNeuronIndexTwo;
    logic [INPUT_LAYER_SIZE-1:0] calcOutput;

always_ff @ (posedge clk or posedge rst) begin
    if (rst) begin
            current_state <= IDLE;
            activeNeuronIndex <= '0;
            done <= 1'b0;

    end else begin
        case(current_state) 

            IDLE : begin
                //When start signal is recieved, send in bram addresses next cycle to read data
                current_state <= IDLE;
                if (start) begin
                    current_state <= WAIT;
                    weight_addr <= activeNeuronIndex;
                    thres_addr <= activeNeuronIndex;
                end
            end

            WAIT : begin
                //The bram addesses sent last state are just received by the BRAM so output will be valid next cycle
                //To keep constant valid input into the np, I requested data from the BRAM for the following neuron below
                nextNeuronIndexTwo = activeNeuronIndex+1;
                weight_addr <= nextNeuronIndexTwo;
                thres_addr <= nextNeuronIndexTwo;
                current_state <= STATE_ONE;
            end
            STATE_ONE : begin
                //Performs calculations on the first requested data.
                //Address from the wait state is just received by the BRAM
                current_state <= STATE_ONE;

                calcOutput = ~(input_array ^ weight_data);
                np_output[activeNeuronIndex] <= ($countones(calcOutput) > thres_data);

                if (activeNeuronIndex ==   NEURONS_PER_NP-1) begin
                    current_state <= IDLE;
                    done <= 1'b1;
                end else begin

                    nextNeuronIndex = activeNeuronIndex+2;
                    //Request data for activeNueron +2 so we can keep constant valid input while accounting for bram delay
                    if(nextNeuronIndex < NEURONS_PER_NP) begin
                        weight_addr <= nextNeuronIndex;
                        thres_addr <= nextNeuronIndex;
                    end
                    activeNeuronIndex <= activeNeuronIndex + 1;
                    done <= 1'b0;
                end
            end

        endcase
    end
    
end

endmodule
