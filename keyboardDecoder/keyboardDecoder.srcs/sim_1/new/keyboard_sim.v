`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2019 03:25:41
// Design Name: 
// Module Name: keyboard_sim
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


module keyboard_sim(
    
    );
    
    reg sysclk;
    
    //Keyboard Inputs
    //reg keyclk;
    //reg keydata;
    
    //Sentence/Word Inputs
    reg nextword;
    reg prevword;
    reg nextsen;
    reg prevsen;
    
    //System Inputs
    reg syson;
    reg holdenable;
    reg changemode;
    reg reset;
    
    //LED Outputs
    wire [3:0] sentenceled;
    wire [7:0] wordled;
    wire led;
    
    //SSD Outputs
    wire [6:0] SSDcathode;
    wire [3:0] SSDanode;
    
    keyboard_TOP system_test(
    .sysclk(sysclk),
    .nextword(nextword),
    .prevword(prevword),
    .nextsen(nextsen),
    .prevsen(prevsen),
    .syson(syson),
    .holdenable(holdenable),
    .changemode(changemode),
    .reset(reset),
    .sentenceled(sentenceled),
    .wordled(wordled),
    .led(led),
    .SSDcathode(SSDcathode),
    .SSDanode(SSDanode)
    );
    
    initial begin
        sysclk = 1'b0;
        forever
        #1 sysclk = ~sysclk;    
    end
    
    initial begin
        nextword = 1'b0;
        prevword = 1'b0;
        nextsen = 1'b0;
        prevsen = 1'b0;
        syson = 1'b1;
        holdenable = 1'b0;
        changemode = 1'b1;
        reset = 1'b0;
    end
    
    //Signal Changes
    initial begin
       #10 nextword = 1'b1;
    end
endmodule
