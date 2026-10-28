// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

reg  [bw-1:0] x0, x1, x2, x3;  // activations (unsigned)
reg  [bw-1:0] w0, w1, w2, w3;  // weights (signed)
reg  [psum_bw-1:0] psum_in;
wire [psum_bw-1:0] psum_out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x0_dec, x1_dec, x2_dec, x3_dec;
integer w0_dec, w1_dec, w2_dec, w3_dec;
integer i; 
integer u; 

function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction



function [3:0] x_bin ;

  input integer activation;

  begin
    if (activation > 7) begin
      x_bin[3] = 1;
      activation = activation - 8;
    end
    else
      x_bin[3] = 0;

    if (activation > 3) begin
      x_bin[2] = 1;
      activation = activation - 4;
    end
    else
      x_bin[2] = 0;

    if (activation > 1) begin
      x_bin[1] = 1;
      activation = activation - 2;
    end
    else
      x_bin[1] = 0;

    if (activation > 0)
      x_bin[0] = 1;
    else
      x_bin[0] = 0;
  end

endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;
  input [3:0] x0, x1, x2, x3;
  input signed [3:0] w0, w1, w2, w3;
  input signed [15:0] c;

  mac_predicted = c + $signed({1'b0, x0}) * w0 + $signed({1'b0, x1}) * w1
                    + $signed({1'b0, x2}) * w2 + $signed({1'b0, x3}) * w3;

endfunction



mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk),
        .x({x3, x2, x1, x0}),
        .w({w3, w2, w1, w0}),
        .psum_in(psum_in),
	.psum_out(psum_out)
);
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<20; i=i+4) begin  // 20 entries per file, 4 per cycle -> 5 cycles

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     w_scan_file = $fscanf(w_file, "%d\n", w0_dec);
     x_scan_file = $fscanf(x_file, "%d\n", x0_dec);

     w_scan_file = $fscanf(w_file, "%d\n", w1_dec);
     x_scan_file = $fscanf(x_file, "%d\n", x1_dec);

     w_scan_file = $fscanf(w_file, "%d\n", w2_dec);
     x_scan_file = $fscanf(x_file, "%d\n", x2_dec);

     w_scan_file = $fscanf(w_file, "%d\n", w3_dec);
     x_scan_file = $fscanf(x_file, "%d\n", x3_dec);

     x0 = x_bin(x0_dec); // unsigned number
     w0 = w_bin(w0_dec); // signed number
     x1 = x_bin(x1_dec); // unsigned number
     w1 = w_bin(w1_dec); // signed number
     x2 = x_bin(x2_dec); // unsigned number
     w2 = w_bin(w2_dec); // signed number
     x3 = x_bin(x3_dec); // unsigned number
     w3 = w_bin(w3_dec); // signed number
     
     psum_in = expected_out;

     expected_out = mac_predicted(x0, x1, x2, x3, w0, w1, w2, w3, psum_in);

  end



  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




