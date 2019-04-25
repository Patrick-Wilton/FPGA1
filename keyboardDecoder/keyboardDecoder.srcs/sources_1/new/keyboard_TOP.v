`timescale 1ns / 1ps

module keyboard_TOP(

    input wire sysclk,
    input wire keyclk,
    input wire keydata,
    input wire syson,
    input wire holdenable,
    output reg [6:0] SSDcathode,
    output wire [3:0] SSDanode,
    output wire [7:0] LEDcode,
    output reg led

    );
    wire [7:0] keycodecheck;
    wire [6:0] SSDcode;
    wire flag;
    reg [7:0] keycodetest;
    reg [7:0] keycode;
    reg [6:0] prevSSD;
    reg keyread;
    
    keyboard_receiver KeyR(.sysclk(sysclk), .keyclk(keyclk), .keydata(keydata), .keycode(keycodecheck), .flag(flag));
    keyboard_decoder KeyD(.decletter(keycode), .sysclk(sysclk), .encSSD(SSDcode));
    
    always @(negedge keyclk) begin
        led <= 1'b1;
    end
    
    always @(posedge sysclk) begin
        if (flag == 1'b1) begin
            keycodetest <= keycodecheck;
        end
    end
    
    always @(keycodetest) begin
        if (keycodetest == 8'hf0) begin
            keyread <= 1'b1;
        end else if (keyread == 1'b1) begin
            keycode <= keycodetest;
            keyread <= 1'b0;
        end
    end
    
    always @(posedge sysclk) begin
        if (syson == 1'b0) begin
            SSDcathode <= 7'b1111111;
            led <= 1'b0;
        end else begin
            if (holdenable) begin
                SSDcathode <= prevSSD;
            end else begin
                SSDcathode <= SSDcode;
                prevSSD <= SSDcathode;
            end
        end
    end
    
    assign LEDcode = keycodecheck;
    assign SSDanode = 4'b0111; 
endmodule
