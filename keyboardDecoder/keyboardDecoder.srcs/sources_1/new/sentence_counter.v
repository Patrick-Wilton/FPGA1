`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2019 03:53:44
// Design Name: 
// Module Name: sentence_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sentence_counter(

    input sysclk,
    input nextword,
    input prevword,
    input nextsen,
    input prevsen,
    input syson,
    input autoread,
    output [3:0] SSDanode,
    output [6:0] SSDcathode,
    output [1:0] sentence,
    output [3:0] word
    
    );
    
    wire nextworddeb;
    wire prevworddeb;
    wire nextsendeb;
    wire prevsendeb;
    
    reg [1:0] SSDcounter;
    reg [3:0] wordcounter = 2'd0;
    reg [1:0] sencounter = 4'd0;
    
    debouncer nwDeb (.sysclk(sysclk), .I(nextword), .O(nextworddeb));
    debouncer pwDeb (.sysclk(sysclk), .I(prevword), .O(prevworddeb));
    debouncer nsDeb (.sysclk(sysclk), .I(nextsen), .O(nextsendeb));
    debouncer psDeb (.sysclk(sysclk), .I(prevsen), .O(prevsendeb));
    
    always @(posedge sysclk) begin
        if (nextworddeb) wordcounter <= wordcounter + 1'b1;
        else if (prevworddeb) wordcounter <= wordcounter - 1'b1;
        else if (nextsendeb) sencounter <= sencounter + 1'b1;
        else if (prevsendeb) sencounter <= sencounter - 1'b1;
    end
    
    
    assign word = wordcounter;
    assign sentence = sencounter;
    
endmodule
