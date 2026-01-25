

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
    //DATA
        //THRESHOLD (32 BIT)
        //WEIGHTS (not sure how many bits come in)
        //INPUTS (not sure how many bits come in)

// OUTPUTS
    //CTRL
        //DONE
    //DATA    
        //Single bit of data out / or the entire sum if it is last step.