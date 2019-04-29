`timescale 1ns / 1ps


module keyboard_encoder(
    
    input wire sysclk,
    input wire save,
    input wire NW,
    input wire PW,
    input wire [1:0] letcounter,
    input wire [2:0] wordcounter,
    input wire [7:0] letter,
    output reg [255:0] customsentence,
    output reg [255:0] currentsentence
    
    );
    reg [31:0] customword = 32'd0;
    reg saveword;
    reg newword;
    reg [1:0] nextstate = 2'd0;
    reg [1:0] state = 2'd0;
    reg [2:0] curWC;
    reg [2:0] prevWC;
    
    always @(*)
        if (save) nextstate = 2'd1;
        else if (NW || PW) nextstate = 2'd2;
        else nextstate = 2'd0;
        
    always @(posedge sysclk) begin
        state <= nextstate;    
    end
    
    always @(wordcounter) begin
        curWC = wordcounter;
        prevWC <= wordcounter;
    end
    
    always @ (state)
        case(state)
            2'd0: begin
                customword[31-(letcounter-2'd1)*8 -: 8] <= letter;
                customsentence[255 - wordcounter*32 -: 32] <= customword;
            end
            2'd1: begin 
                currentsentence[255 - prevWC*32 -: 32] <= customsentence[255 - prevWC*32 -: 32];
                customword <= currentsentence[255 - curWC*32 -: 32];
            end
            2'd2: begin
                customsentence[255 - prevWC*32 -: 32] <= currentsentence[255 - prevWC*32 -: 32];
                customword <= currentsentence[255 - curWC*32 -: 32];
            end
        endcase
    
endmodule
