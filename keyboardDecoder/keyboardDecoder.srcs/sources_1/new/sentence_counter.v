`timescale 1ns / 1ps


module sentence_counter(

    input wire sysclk,
    input wire nextword,
    input wire prevword,
    input wire nextsen,
    input wire prevsen,
    input wire syson,
    input wire autoread,
    input wire reset,
    
    output reg [3:0] SSDanode,
    output reg [6:0] SSDcathode,
    output wire [1:0] sentenceled,
    output wire [3:0] wordled
    
    );
    
    wire nextworddeb;
    wire prevworddeb;
    wire nextsendeb;
    wire prevsendeb;
    
    wire [7:0] letter;
    
    reg [1:0] SSDcounter = 2'd0;
    reg [3:0] wordcounter = 4'd0;
    reg [1:0] sencounter = 2'd0;
    
    doubledebounce wordDeb (
    .X0(prevword),
    .X1(nextword),
    .sysclk(sysclk),
    .reset(reset),
    .X0_deb(prevworddeb),
    .X1_deb(nextworddeb)
    );
    
    doubledebounce senDeb (
    .X0(prevsen),
    .X1(nextsen),
    .sysclk(sysclk),
    .reset(reset),
    .X0_deb(prevsendeb),
    .X1_deb(nextsendeb)
    );
    
    sentence_decoder SenD (
        .sysclk(sysclk),
        .sencounter(sencounter),
        .wordcounter(wordcounter),
        .SSDcounter(SSDcounter),
        .letter(letter)
    );
    
    keyboard_decoder LetD (.decletter(letter), .sysclk(sysclk), .encSSD(SSDcathode));
    
    always @(posedge sysclk) begin
        if (nextworddeb) wordcounter <= wordcounter + 1'b1;
        else if (prevworddeb) wordcounter <= wordcounter - 1'b1;
        else if (nextsendeb) sencounter <= sencounter + 1'b1;
        else if (prevsendeb) sencounter <= sencounter - 1'b1;
    end
    
    always @(posedge sysclk) begin
        SSDcounter <= SSDcounter + 1'b1;
        case(SSDcounter)
            2'd0: SSDanode = 4'b0111;
            2'd1: SSDanode = 4'b1011;
            2'd2: SSDanode = 4'b1101;
            2'd3: SSDanode = 4'b1110;
        endcase
    end
    
    assign wordled = wordcounter;
    assign sentenceled = sencounter;
    
endmodule
