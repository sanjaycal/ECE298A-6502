`ifndef STATUS_REGISTER_INDICIES
    `define STATUS_REGISTER_INDICIES 1

    //OPCODE

    `define CARRY_FLAG              7'b0000001
    `define ZERO_FLAG               7'b0000010
    `define INTERRUPT_DISABLE_FLAG  7'b0000100
    `define DECIMAL_MODE_FLAG       7'b0001000
    `define BRK_FLAG                7'b0010000
    `define OVERFLOW_FLAG           7'b0100000
    `define NEGATIVE_FLAG           7'b1000000



`endif
