`timescale 1ns / 1ps

module LCD_cursor_tb();

reg rst,clk;
reg [9:0] number_btn;
reg [1:0] control_btn;

wire LCD_E, LCD_RS, LCD_RW;
wire [7:0] LCD_DATA, LED_OUT;

LCD_cursor u1(.rst(rst), .clk(clk), .LCD_E(LCD_E), .LCD_RS(LCD_RS), .LCD_RW(LCD_RW), .LCD_DATA(LCD_DATA), .LED_OUT(LED_OUT), .number_btn(number_btn), .control_btn(control_btn));

always begin
   #2 clk <= ~clk; 
    end
    
initial begin
    clk = 0;
    rst = 1;

    number_btn =0;
    control_btn =0;
    #1 rst =0;
    #1 rst = 1;
    #1200 number_btn = 10'b0001000000;
    #100 number_btn = 10'b0000000000;
    #100 number_btn = 10'b0000001000;
    #100 number_btn = 10'b0000000000;
    #100 control_btn = 2'b10;
    #200 control_btn = 2'b01;
    #1000
    $stop;   
end

endmodule