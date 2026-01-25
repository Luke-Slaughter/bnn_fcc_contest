

// Need to interface with memory 
// Some external module with interface with this feeding in the weights and values
    // These weights are already in memory
    // So maybe some counter counts up the addresses to go to the ram to interface with this
    // And same for output, every new value with a done signal is fed to ram

//Question:
    //Is inputs continuously streaming in? How to deal with this
    //Weights and thresholds are stored in memory but what about inputs
    //Answer:
        //Use an I/O buffer

// INPUTS
    //CTRL
        //START
        //If this is a hidden layer (if it is then it will skip the threshold phase and output the sum)
        //NUM of INPUTS expected / when to stop?
        //RST
    //DATA
        //THRESHOLD (32 BIT)
        //WEIGHTS (not sure how many bits come in)
        //INPUTS (not sure how many bits come in)

// OUTPUTS
    //CTRL
        //DONE
    //DATA    
        //Single bit of data out / or the entire sum if it is last step.

module np_1 #(
    parameter int WIDTH_EX_IN,
    parameter int THRESHOLD_DATA_WIDTH
) 
(
    input logic start,
    input logic is_hidden,
    input logic [WIDTH_EX_IN-1:0] num_expected_inputs,
    input logic rst,
    
    input logic [THRESHOLD_DATA_WIDTH-1:0] threshold,
    input logic weight,
    input logic data_in,

    output logic done,
    output logic data_out,
);

    typedef enum logic [1:0] {
        IDLE,
        WAIT,     
        THRESHOLD,  
        DONE,     
        OPERATE    
    } state_t;

    state_t current_state, next_state;

    logic [THRESHOLD_DATA_WIDTH-1:0] sum;
    logic [WIDTH_EX_IN-1:0] count;

    always_ff @(posedge clk or posedge rst) begin
        
        if rst begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        //set everything to 0/hold
        next_state = current_state;

        case(current_state)
            IDLE: begin
                if
            end
            WAIT: begin
                
            end
            THRESHOLD: begin
                
            end
            DONE: begin
                
            end
            OPERATE: begin
                
            end
        endcase
    end
endmodule