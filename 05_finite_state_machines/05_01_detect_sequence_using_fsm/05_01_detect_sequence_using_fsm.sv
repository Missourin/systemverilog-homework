//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module detect_4_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Detection of the "1010" sequence

  // States (F — First, S — Second)
  enum logic[2:0]
  {
     IDLE = 3'b000,
     F1   = 3'b001,
     F0   = 3'b010,
     S1   = 3'b011,
     S0   = 3'b100
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      IDLE: if (  a) new_state = F1;
      F1:   if (~ a) new_state = F0;
      F0:   if (  a) new_state = S1;
            else     new_state = IDLE;
      S1:   if (~ a) new_state = S0;
            else     new_state = F1;
      S0:   if (  a) new_state = S1;
            else     new_state = IDLE;
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic (depends only on the current state)
  assign detected = (state == S0);

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module detect_6_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Task:
  // Implement a module that detects the "110011" input sequence
  //
  // Hint: See Lecture 3 for details

  enum logic [2:0]
  {
    IDLE   = 3'b000,
    P1     = 3'b001,
    P11    = 3'b010,
    P110   = 3'b011,
    P1100  = 3'b100,
    P11001 = 3'b101,
    FOUND  = 3'b110
  }
  state, new_state;

  always_comb begin
    new_state = state;

    case (state)
      IDLE   : if (  a) new_state = P1;
      P1     : if (  a) new_state = P11;
               else     new_state = IDLE;
      P11    : if (~ a) new_state = P110;
      P110   : if (~ a) new_state = P1100;
               else     new_state = P1;
      P1100  : if (  a) new_state = P11001;
               else     new_state = IDLE;
      P11001 : if (  a) new_state = FOUND;
               else     new_state = IDLE;
      FOUND  : if (  a) new_state = P11;
               else     new_state = P110;
    endcase
  end

  assign detected = (state == FOUND);

  always_ff @(posedge clk)
    if (rst) state <= IDLE;
    else     state <= new_state;

endmodule