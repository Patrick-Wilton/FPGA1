`timescale 1ns / 1ps

module keyboard_TOP(

    //System Clock
    input wire sysclk,
    
    //Keyboard Inputs
    input wire keyclk,
    input wire keydata,
    
    //Sentence/Word Inputs
    input wire nextword,
    input wire prevword,
    input wire nextsen,
    input wire prevsen,
    //input wire autoread,
    
    //System Inputs
    input wire syson,
    input wire holdenable,
    input wire changemode,
    input wire reset,
    
    //LED Outputs
    output reg [3:0] sentenceled,
    output reg [7:0] wordled,
    output reg led,
    
    //SSD Outputs
    output reg [6:0] SSDcathode,
    output reg [3:0] SSDanode
    );
    
    
    //Keyboard Variables
    wire [7:0] keycodecheck;
    wire [6:0] SSDcode;
    wire flag;
    reg [7:0] keycodetest;
    reg [7:0] keycode;
    reg [6:0] prevSSD;
    reg keyread;
    
    //Sentence Reader Variables
    wire nextworddeb;
    wire prevworddeb;
    wire nextsendeb;
    wire prevsendeb;
    wire [7:0] letter;
    reg [1:0] SSDcounter = 2'd0;
    reg [3:0] wordcounter = 4'd0;
    reg [1:0] sencounter = 2'd0;
    wire [6:0] tempSSDcathode;
    reg [3:0] tempSSDanode;
    
    //Keyboard Submodules
    keyboard_receiver KeyR(.sysclk(sysclk), .keyclk(keyclk), .keydata(keydata), .keycode(keycodecheck), .flag(flag));
    keyboard_decoder KeyD(.decletter(keycode), .sysclk(sysclk), .encSSD(SSDcode));
    
    //Sentence Submodules
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
    
    keyboard_decoder LetD (.decletter(letter), .sysclk(sysclk), .encSSD(tempSSDcathode));
    
    //System Level Reset
    always @(posedge sysclk) begin
        if (reset == 1'b1) begin
            keycode <= 8'd0;
            SSDcounter <= 2'd0;
            wordcounter <= 4'd0;
            sencounter <= 2'd0;
        end
    end
    
    //Assigns a testing variable if the keydata flag was raised
    always @(posedge sysclk) begin
        if (flag == 1'b1) begin
            keycodetest <= keycodecheck;
        end
    end
    
    //Checks if the key was released then reads the next scan code
    always @(keycodetest) begin
        if (keycodetest == 8'hf0) begin
            keyread <= 1'b1;
        end else if (keyread == 1'b1) begin
            keycode <= keycodetest;
            keyread <= 1'b0;
        end
    end
    
    // Increasing and decreasing sentence/word counters
     always @(posedge sysclk) begin
        if (nextworddeb == 1'b1) wordcounter <= wordcounter + 4'd1;
        else if (prevworddeb == 1'b1) wordcounter <= wordcounter - 4'd1;
        else if (nextsendeb == 1'b1) sencounter <= sencounter + 2'd1;
        else if (prevsendeb == 1'b1) sencounter <= sencounter - 2'd1;
    end
    
    //Assigns SSD anode depending on current letter
    always @(posedge sysclk) begin
        SSDcounter <= SSDcounter + 2'd1;
        case(SSDcounter)
            2'd0: tempSSDanode = 4'b0111;
            2'd1: tempSSDanode = 4'b1011;
            2'd2: tempSSDanode = 4'b1101;
            2'd3: tempSSDanode = 4'b1110;
        endcase
    end
    
    // Keyboard System functionality
    always @(posedge sysclk) begin
        if (syson == 1'b0) begin
            SSDcathode <= 7'b1111111;
            led <= 1'b0;
        end else if (changemode == 1'b0) begin
            if (holdenable) begin
                SSDcathode <= prevSSD;
                SSDanode <= 4'b0111;
            end else begin
                SSDcathode <= SSDcode;
                prevSSD <= SSDcathode;
                SSDanode <= 4'b0111;
            end
        end else if (changemode == 1'b1) begin
            led <= 1'b1;
            SSDcathode <= tempSSDcathode;
            SSDanode <= tempSSDanode;
        end
    end
    
    //Assigns sentence and word LED indicators
    always @(posedge sysclk) begin
        case(wordcounter)
            4'd0: wordled = 8'b10000000;
            4'd1: wordled = 8'b11000000;
            4'd2: wordled = 8'b11100000;
            4'd3: wordled = 8'b11110000;
            4'd4: wordled = 8'b11111000;
            4'd5: wordled = 8'b11111100;
            4'd6: wordled = 8'b11111110;
            4'd7: wordled = 8'b11111111;
        endcase
        case(sencounter)
            2'd0: sentenceled = 4'b1000;
            2'd1: sentenceled = 4'b1100;
            2'd2: sentenceled = 4'b1110;
            2'd3: sentenceled = 4'b1111;
        endcase
    end
    
endmodule
