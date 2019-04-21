`timescale 1ns / 1ps

module keyboard_decoder(
    input wire [7:0] decletter,
    input wire sysclk,
    output reg [6:0] encSSD
    );
    
    // Vowels
    parameter A = 8'h1C;
    parameter E = 8'h24;
    parameter I = 8'h43;
    parameter O = 8'h44;
    parameter U = 8'h3C;
    
    //Consonants
    parameter b = 8'h32;
    parameter C = 8'h21;
    parameter d = 8'h23;
    parameter F = 8'h2B;
    parameter G = 8'h34;
    parameter H = 8'h33;
    parameter L = 8'h4B;
    parameter n = 8'h31;
    parameter P = 8'h4D;
    parameter r = 8'h2D;
    parameter S = 8'h1B;
    parameter t = 8'h2C;
    
    always @(posedge sysclk) begin
        case(decletter)
            A: encSSD = 7'b0001000;
            E: encSSD = 7'b0110000;
            I: encSSD = 7'b1001111;
            O: encSSD = 7'b0000001;
            U: encSSD = 7'b1000001;
            b: encSSD = 7'b1100000;
            C: encSSD = 7'b0110001;
            d: encSSD = 7'b1000010;
            F: encSSD = 7'b0111000;
            G: encSSD = 7'b0100000;
            H: encSSD = 7'b1001000;
            L: encSSD = 7'b1110001;
            n: encSSD = 7'b1101010;
            P: encSSD = 7'b0011000;
            r: encSSD = 7'b1111010;
            S: encSSD = 7'b0100100;
            t: encSSD = 7'b1110000;
            default: encSSD = 7'b1111110;
        endcase
    end 
endmodule
