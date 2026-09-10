//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

// A non-parameterized module
// that implements the signed multiplication of 4-bit numbers
// which produces 8-bit result

module signed_mul_4
(
  input  signed [3:0] a, b,
  output signed [7:0] res
);

  assign res = a * b;

endmodule

// A parameterized module
// that implements the unsigned multiplication of N-bit numbers
// which produces 2N-bit result

module unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  output [2 * n - 1:0] res
);

  assign res = a * b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

// Task:
//
// Implement a parameterized module
// that produces either signed or unsigned result
// of the multiplication depending on the 'signed_mul' input bit.

module signed_or_unsigned_mul
# (
  parameter n = 8
)
(
  input        [    n - 1:0] a, b,
  input                      signed_mul,
  output logic [2 * n - 1:0] res
);

  // always_comb begin
  //   if (signed_mul)
  //     res = $signed(a) * $signed(b);
  //   else
  //     res = a * b;
  // end

  wire [n:0] a_extended = signed_mul ? {a[n-1], a} : {1'b0, a};
  wire [n:0] b_extended = signed_mul ? {b[n-1], b} : {1'b0, b};

  assign res = $signed(a_extended) * $signed(b_extended);

endmodule
