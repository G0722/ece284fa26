// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

// for Q3
// Gordon Yang
module mac (psum_out, x, w, psum_in);

parameter bw = 4;
parameter psum_bw = 16;

input signed [psum_bw-1:0] psum_in;

input [4*bw-1:0] x;  // {x3, x2, x1, x0}, x0 in the LSBs

input [4*bw-1:0] w;  // {w3, w2, w1, w0}, w0 in the LSBs

output signed [psum_bw-1:0] psum_out;

wire signed [2*bw-1:0] p[3:0];
wire signed [2*bw:0] isum[1:0];

genvar i;

for (i = 0; i < 4; i=i+1)
    assign p[i] = $signed({1'b0, x[bw*i +: bw]}) * $signed(w[bw*i +: bw]);

for (i = 0; i < 3; i=i+2)
    assign isum[i/2] = p[i] + p[i+1];

assign psum_out = isum[0] + isum[1] + psum_in;


endmodule
