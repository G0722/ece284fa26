// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_wrapper (clk, psum_out, x, w, psum_in);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] psum_out;
input  [4*bw-1:0] x;  // {x3, x2, x1, x0}, x0 in the LSBs
input  [4*bw-1:0] w;  // {w3, w2, w1, w0}, w0 in the LSBs
input  [psum_bw-1:0] psum_in;
input  clk;

reg    [4*bw-1:0] x_q;
reg    [4*bw-1:0] w_q;
reg    [psum_bw-1:0] psum_in_q;
/*
mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(out)
); */

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .x(x_q),
        .w(w_q),
        .psum_in(psum_in_q),
	.psum_out(psum_out)
);


always @ (posedge clk) begin
        w_q        <= w;
        x_q        <= x;
        psum_in_q  <= psum_in;
end

endmodule
