//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input        [3:0] a, b,
  output logic [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  always_comb begin
    sum = a + b;

    if ((a[3] == 1'b0) && (b[3] == 1'b0) && (sum[3] != a[3]))
      sum = 4'b0111;
    else if ((a[3] == 1'b1) && (b[3] == 1'b1) && (sum[3] != a[3]))
      sum = 4'b1000;
  end

endmodule
