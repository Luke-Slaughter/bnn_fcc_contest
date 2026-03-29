module neuron #(
    parameter INPUT_SIZE = 784,
    parameter THRESHOLD_SIZE = 32

)(
    input logic clk,
    input logic enable,
    input logic weights[INPUT_SIZE-1 : 0],
    input logic threshold [THRESHOLD_SIZE -1 : 0],
    input logic inputs[INPUT_SIZE-1 : 0],
    output logic neuron_out [THRESHOLD_SIZE-1 : 0]
);

integer i;
logic accumulation(THRESHOLD_SIZE*2-1 : 0);

always_ff @ (posedge clk) begin

    for(i = 0; i < INPUT_SIZE; i++) begin
        accumulation = accumulation + (inputs[i]*weights[i]);
    end
    
    neuron_out <= (accumulation > threshold) ? 1'b1 : 1'b0;

end
endmodule