// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, A, B, format, acc, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;
input signed [bw-1:0] B;

output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

reg signed [psum_bw-1:0] p;

assign out = psum_q;

// calculates the product a_q*b_q based on the format
always @(*) begin
	case(format)
		1'b0: p = a_q * b_q;	// signed version
		1'b1: begin		// sign-magnitude version
			p = {a_q[bw-1]^b_q[bw-1], {{bw{1'b0}}, a_q[bw-2:0]} * {{bw{1'b0}}, b_q[bw-2:0]}};
		end
		default: p = a_q * b_q;
	endcase
end

// Your code goes here
always @(posedge clk) begin
	if (reset)
		psum_q <= 0;
	else begin
		if (acc) begin	// implements the summation of a_q*b_q + psum_q
			case(format)
				1'b0: psum_q <= p + psum_q;		// signed version
				1'b1: begin				// sign-magnitude version
					if (p[psum_bw-1] == psum_q[psum_bw-1]) begin	// case where p and psum_q are same signs
						// add their magnitudes, copy sign from p or psum_q
						psum_q[psum_bw-2:0] <= psum_q[psum_bw-2:0] + p[psum_bw-2:0];
						psum_q[psum_bw-1] <= p[psum_bw-1];
					end
					else begin	// p and psum_q have different signs
						// case p is bigger magnitude
						if (p[psum_bw-2:0] > psum_q[psum_bw-2:0]) begin
							// do |p| - |psum_q|, then copy over sign of p
							psum_q[psum_bw-2:0] <= p[psum_bw-2:0] - psum_q[psum_bw-2:0];
							psum_q[psum_bw-1] <= p[psum_bw-1];
						end
						// case psum_q is bigger magnitude
						else if (p[psum_bw-2:0] < psum_q[psum_bw-2:0]) begin
							// do |psum_q| - |p|, then copy over psum_q's sign
							psum_q[psum_bw-2:0] <= psum_q[psum_bw-2:0] - p[psum_bw-2:0];
							psum_q[psum_bw-1] <= psum_q[psum_bw-1];
						end
						//opposite sign, but equal magnitude sums to 0.
						else
							psum_q <= 0;
					end
				end
			endcase
		end
		else begin	// don't accumulate the sum. copy over p directly
			psum_q <= p;
		end

	end
		
	a_q <= A;
	b_q <= B;
end

endmodule

