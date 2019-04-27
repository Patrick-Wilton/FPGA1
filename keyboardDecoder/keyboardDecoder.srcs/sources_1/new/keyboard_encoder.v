`timescale 1ns / 1ps


module keyboard_encoder(
    
    input wire save,
    input wire [1:0] letcounter,
    input wire [2:0] wordcounter,
    input wire [7:0] letter,
    output reg [255:0] customsentence
    
    );
    reg [31:0] customword;
    reg [255:0] currentsentence;
    
    always @(*) begin
        customword[31-letcounter*8 -: 8] = letter;
        customsentence[255 - wordcounter*32 -: 32] = customword;
    end
    
    always @(wordcounter) begin
        if (save == 1'b1) begin
            currentsentence[255 - wordcounter*32 -: 32] = customsentence[255 - wordcounter*32 -: 32];
        end
    end
    
endmodule
