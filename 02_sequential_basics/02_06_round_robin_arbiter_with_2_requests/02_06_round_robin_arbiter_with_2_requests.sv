//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input              clk,
    input              rst,
    input        [1:0] requests,
    output logic [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic priority_guest;

    always_comb begin
        grants = 2'b00;

        case (requests)
            2'b01: grants = 2'b01;
            2'b10: grants = 2'b10;
            2'b11: begin
                if (priority_guest) grants = 2'b01;
                else                grants = 2'b10;
            end
            default: grants = 2'b00;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
        begin
            priority_guest <= '1;
        end
        else
        begin
            if      (grants == 2'b01) priority_guest <= '0;
            else if (grants == 2'b10) priority_guest <= '1;
            else                      priority_guest <= priority_guest;
        end

endmodule
