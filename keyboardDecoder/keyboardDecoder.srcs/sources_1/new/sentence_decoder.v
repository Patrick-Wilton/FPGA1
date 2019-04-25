`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2019 04:17:13
// Design Name: 
// Module Name: sentence_decoder
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


module sentence_decoder(
    
    input sysclk,
    input [1:0] sencounter,
    input [3:0] wordcounter,
    input [1:0] SSDcounter,
    output [7:0] letter
    
    );
    
    reg [255:0] sentence;
    reg [31:0] word;
    
    reg [255:0] sen1 = 256'h2144444B_211C2C1B_2D3C4B24_002C3324_4B443134_002D2423_2D441C23_00000000;
    reg [255:0] sen2;
    reg [255:0] sen3;
    
    always @(posedge sysclk) begin
        case(sencounter)
            2'd0: sentence = sen1;
            2'd1: sentence = sen2;
            2'd2: sentence = sen3;
            default: sentence = 256'd0;
        endcase
        word <= sentence[255 - 32*wordcounter:255 - 32*(wordcounter+1)];
        letter <= word[31-8*SSDcounter:31-8*(SSDcounter+1)];
    end
    
    
endmodule
