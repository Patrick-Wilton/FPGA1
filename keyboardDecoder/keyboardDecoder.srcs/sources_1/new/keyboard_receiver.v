`timescale 1ns / 1ps

module keyboard_receiver(
    input wire sysclk,
    input wire keyclk,
    input wire keydata,
    output reg [7:0] keycode,
    output reg flag
    );
    
    reg [3:0] keycount = 0;
    
    always @(negedge keyclk) begin
        case(keycount)
            4'd0: flag = 1'b0;
            4'd1: keycode[0] = keydata;
            4'd2: keycode[1] = keydata;
            4'd3: keycode[2] = keydata;
            4'd4: keycode[3] = keydata;
            4'd5: keycode[4] = keydata;
            4'd6: keycode[5] = keydata;
            4'd7: keycode[6] = keydata;
            4'd8: keycode[7] = keydata;
            4'd9: flag = 1'b1;
            4'd10: flag = 1'b0;
        endcase
        if (keycount <= 4'd9) keycount <= keycount + 4'd1;
        else if (keycount == 4'd10) keycount <= 4'd0;
    end
    
    
endmodule
