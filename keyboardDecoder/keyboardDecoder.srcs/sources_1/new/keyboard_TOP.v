`timescale 1ns / 1ps


module keyboard_TOP(

    input wire sysclk,
    input wire keyclk,
    input wire keydata,
    input wire syson,
    input wire holdenable,
    output reg [6:0] SSDcathode,
    output wire [3:0] SSDanode

    );
    wire keycodecheck;
    wire SSDcode;
    reg [7:0] keycode;
    reg [6:0] prevSSD;
    reg keyread;
    
    keyboard_receiver KeyR(.sysclk(sysclk), .keyclk(keyclk), .keydata(keydata), .keycode(keycodecheck));
    
    always @(posedge sysclk) begin
        if (keycodecheck == 8'hf0) begin
            keyread <= 1'b1;
        end else if (keyread == 1'b1) begin
            keycode <= keycodecheck;
            keyread <= 1'b0;
        end
    end
    
    keyboard_decoder KeyD(.decletter(keycode), .encSSD(SSDcode));
    
    always @(posedge sysclk) begin
        if (~syson) begin
            SSDcathode = 7'b0;
        end else begin
            if (holdenable) begin
                SSDcathode <= prevSSD;
            end else begin
                SSDcathode <= SSDcode;
                prevSSD <= SSDcathode;
            end
        end
    end
    
    assign SSDanode = 4'b0111;
    
endmodule
