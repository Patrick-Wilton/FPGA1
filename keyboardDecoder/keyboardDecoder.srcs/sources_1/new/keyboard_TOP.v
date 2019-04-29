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
    input wire autoread,
    
    //Sentence Write Inputs
    input wire keywrite,
    
    //System Inputs
    input wire syson,
    input wire holdenable,
    input wire changemode,
    input wire reset,
    
    //LED Outputs
    output reg [3:0] sentenceled,
    output reg [7:0] wordled,
    output reg [1:0] ledmode,
    
    //SSD Outputs
    output reg [6:0] SSDcathode,
    output reg [3:0] SSDanode
    );
    
    /////////////////////////////////////////////////////////////////////////////////////////
    
    //Keyboard Variables
    wire [7:0] keycodecheck;
    wire [6:0] SSDcode;
    wire flag;
    reg [7:0] keycodetest;
    reg [7:0] keycode;
    reg [6:0] prevSSD;
    reg keyread;
    reg tempprevSSD;
    reg arrow;
    
    //Sentence Reader Variables
    wire nextworddeb;
    wire prevworddeb;
    wire nextsendeb;
    wire prevsendeb;
    wire anodepulse;
    wire autopulse;
    wire [7:0] letter;
    reg [1:0] SSDcounter = 2'd0;
    reg [2:0] wordcounter = 3'd0;
    reg [1:0] sencounter = 2'd0;
    wire [6:0] tempSSDcathode;
    reg [3:0] tempSSDanode;
    
    //Sentence Writer Variables
    reg [1:0] letcounter = 2'd0;
    reg [7:0] keystore;
    wire [255:0] customsentence;
    wire [255:0] currentsentence;
    
    //Keyboard Submodules
    keyboard_receiver KeyR(.sysclk(sysclk), .keyclk(keyclk), .keydata(keydata), .keycode(keycodecheck), .flag(flag));
    keyboard_decoder KeyD(.decletter(keycode), .sysclk(sysclk), .encSSD(SSDcode));
    
    keyboard_encoder KeyE(
    .sysclk(sysclk),
    .save(nextsendeb),
    .NW(nextworddeb),
    .PW(prevworddeb),
    .letcounter(letcounter),
    .wordcounter(wordcounter), 
    .letter(keystore), 
    .currentsentence(currentsentence), 
    .customsentence(customsentence)
    );
    
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
    .keywrite(keywrite),
    .currentsentence(currentsentence),
    .customsentence(customsentence),
    .sencounter(sencounter),
    .wordcounter(wordcounter),
    .SSDcounter(SSDcounter),
    .letter(letter)
    );
    
    keyboard_decoder LetD (.decletter(letter), .sysclk(sysclk), .encSSD(tempSSDcathode));
    heartbeat #(19) SSDpulse (.sysclk(sysclk), .reset(reset), .pulse(anodepulse));
    heartbeat #(26) Readpulse (.sysclk(sysclk), .reset(reset), .pulse(autopulse));
    
    //Assigns a testing variable if the keydata flag was raised
    always @(posedge sysclk) begin
        if (flag == 1'b1) begin
            keycodetest <= keycodecheck;
        end
        if (keyread == 1'b1 && arrow == 1'b0) begin
            arrow <= 1'b1;
        end else if (arrow == 1'b1) arrow = 1'b0;
    end
    
    //Checks if the key was released then reads the next scan code
    always @(keycodetest) begin
        if (keycodetest == 8'hf0) begin
            keyread <= 1'b1;
        end else if (keycodetest == 8'he0) begin
            keyread <= 1'b1;
        end else if (keyread == 1'b1) begin
            if (keywrite == 1'b0) begin
                keycode <= keycodetest;
                keyread <= 1'b0;
            end else begin
                if (keycodetest == 8'h66 && letcounter > 2'd0) begin
                    keystore <= 8'd0;
                    letcounter <= letcounter - 2'd1;
                    keyread <= 1'b0;
                end else if (letcounter < 2'd3) begin
                    keystore <= keycodetest;
                    letcounter <= letcounter + 2'd1;
                    keyread <= 1'b0;
                end
            end
        end
    end
    
    // Increasing and decreasing sentence/word counters
     always @(posedge sysclk) begin
     
        if (autoread == 1'b1 && autopulse == 1'b1) wordcounter <= wordcounter + 3'd1;
        else if (autoread == 1'b0 && (nextworddeb == 1'b1 || (keycode == 8'h74 && arrow == 1'b1))) wordcounter <= wordcounter + 3'd1;
        else if (autoread ==1'b0 && (prevworddeb == 1'b1 || (keycode == 8'h6B && arrow == 1'b1))) wordcounter <= wordcounter - 3'd1;
        
        if (keywrite == 1'b0) begin
            if (nextsendeb == 1'b1 || (keycode == 8'h75 && flag == 1'b1)) begin
                sencounter <= sencounter + 2'd1;
            end else if (prevsendeb == 1'b1 || (keycode == 8'h72 && flag == 1'b1)) begin
                sencounter <= sencounter - 2'd1;
            end
        end
        
    end
    
    //Assigns SSD anode depending on current letter
    always @(posedge anodepulse) begin
        SSDcounter <= SSDcounter + 2'd1;
    end
    
    // Keyboard System functionality
    always @(posedge sysclk) begin
        if (syson == 1'b0) begin
            SSDcathode <= 7'b1111111;
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
            SSDcathode <= tempSSDcathode;
            SSDanode <= tempSSDanode;
        end
    end
    
    //Assigns sentence, word and SSD LEDs
    always @(posedge sysclk) begin
        case(SSDcounter)
            2'd0: tempSSDanode = 4'b0111;
            2'd1: tempSSDanode = 4'b1011;
            2'd2: tempSSDanode = 4'b1101;
            2'd3: tempSSDanode = 4'b1110;
        endcase
        case(wordcounter)
            3'd0: wordled = 8'b10000000;
            3'd1: wordled = 8'b11000000;
            3'd2: wordled = 8'b11100000;
            3'd3: wordled = 8'b11110000;
            3'd4: wordled = 8'b11111000;
            3'd5: wordled = 8'b11111100;
            3'd6: wordled = 8'b11111110;
            3'd7: wordled = 8'b11111111;
        endcase
        case(sencounter)
            2'd0: sentenceled = 4'b1000;
            2'd1: sentenceled = 4'b1100;
            2'd2: sentenceled = 4'b1110;
            2'd3: sentenceled = 4'b1111;
        endcase
        if (changemode == 1'b0 && keywrite == 1'b0) ledmode = 2'b10;
        else if (changemode == 1'b1 && keywrite == 1'b0) ledmode = 2'b01;
        else if (changemode == 1'b1 && keywrite == 1'b1) ledmode = 2'b11;
        else if (changemode == 1'b0 && keywrite == 1'b1) ledmode = 2'b00;
    end
endmodule
