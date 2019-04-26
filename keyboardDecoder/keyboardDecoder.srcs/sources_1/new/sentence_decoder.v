`timescale 1ns / 1ps


module sentence_decoder(
    
    input wire sysclk,
    input wire [1:0] sencounter,
    input wire [3:0] wordcounter,
    input wire [1:0] SSDcounter,
    output reg [7:0] letter
    
    );
    
    reg [255:0] sentence;
    reg [31:0] word;
    
    reg [255:0] sen1 = 256'h2144444B_211C2C1B_2D3C4B24_002C3324_4B443134_002D2423_2D441C23_00000000;
    reg [255:0] sen2 = 256'h2B4D341C_0000431B_002C4444_331C2D23_002B442D_00003C1B_001C4B4B_00000000;
    reg [255:0] sen3 = 256'h4D1C1B1B_002C3324_1B1C4B2C_00002C44_002C3324_432D4431_2133242B_00000000;
    reg [255:0] sen4 = 256'h002C3324_00324334_32241C2D_001C2C24_002C3324_324B3C24_1B241C4B_00000000;
    
    always @(posedge sysclk) begin
        case(sencounter)
            2'd0: sentence = sen1;
            2'd1: sentence = sen2;
            2'd2: sentence = sen3;
            2'd3: sentence = sen4;
            default: sentence = 256'd0;
        endcase
        word <= sentence[255-wordcounter*32 +: 32];
        letter <= word[31-8*SSDcounter +: 8];
    end
    
    
endmodule
