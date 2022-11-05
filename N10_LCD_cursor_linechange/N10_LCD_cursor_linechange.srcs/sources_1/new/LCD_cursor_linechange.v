`timescale 1ns / 1ps

module LCD_cursor(rst, clk, btn, LCD_E, LCD_RS, LCD_RW, LCD_DATA, LED_OUT, number_btn, control_btn);

input rst,clk;
input btn; // line 1,2 change
input [9:0] number_btn;
input [1:0] control_btn;

wire [9:0] number_btn_t;
wire [1:0] control_btn_t;

oneshot_universal #(.width(12)) uut(.clk(clk), .rst(rst), .btn({number_btn , control_btn}), .btn_trig({number_btn_t , control_btn_t}));

output LCD_E;
output reg LCD_RS, LCD_RW;
output reg [7:0] LCD_DATA, LED_OUT;

reg [7:0] cnt;   
reg [2:0] state;
reg [7:0] ccnt;

parameter DELAY =4'b0000,
          FUNCTION_SET =4'b0001,
          DISP_ONOFF =4'b0010,
          ENTRY_MODE =4'b0011,
          SET_ADDRESS =4'b0100,
          SET_LINE_1=4'b0101,
          SET_LINE_2=4'b0110,
          DELAY_T =4'b0111,
          WRITE =4'b1000,
          CURSOR =4'b1001;

          
reg line = 1'b0;
          
always @(posedge clk or negedge rst)
begin
    if(!rst) begin
        state <= DELAY;
        cnt <= 0;
        LED_OUT <= 0;
        end
    else
    begin
        case(state)
        DELAY :begin
            if(cnt >=70) cnt <= 0;
            else cnt <= cnt+1;
            LED_OUT <= 8'b1000_0000;
            if(cnt == 70) state <= FUNCTION_SET;
        end
        FUNCTION_SET :begin
            if(cnt >=30) cnt <= 0;
            else cnt <= cnt+1;
            LED_OUT <= 8'b0100_0000;
            if(cnt == 30) state <= DISP_ONOFF;
        end
        DISP_ONOFF :begin
            if(cnt >=30) cnt <= 0;
            else cnt <= cnt+1;
            LED_OUT <= 8'b0010_0000;
            if(cnt == 30) state <= ENTRY_MODE;
        end
        ENTRY_MODE :begin
            if(cnt >=30) cnt <= 0;
            else cnt <= cnt+1;
            LED_OUT <= 8'b0001_0000;
            if(cnt == 30) state <= SET_ADDRESS;
        end
        SET_ADDRESS: begin
           if(cnt == 100) begin
              if(!line) begin
              state <= SET_LINE_1;
              end
           else begin
              state <= SET_LINE_2;
           end
        end
             LED_OUT <= 8'b0000_1000;
        end
        SET_LINE_1: begin
        if(cnt >= 30) cnt <= 0;
          else cnt <= cnt + 1;
         state <= (btn)? SET_LINE_2:DELAY_T;
        line <= 1'b0;
        ccnt <= 7'b0000000;
        end
        SET_LINE_2: begin
          if(cnt >= 30) cnt <= 0;
        else cnt <= cnt + 1;
        state <= (!btn)? SET_LINE_1:DELAY_T;
        line <= 1'b1;
        ccnt <=7'b1000000;
        end
        DELAY_T :begin
            cnt <= 0;
            LED_OUT <= 8'b0000_0100;
            state <= |number_btn_t ? WRITE : (|control_btn_t ? CURSOR : DELAY_T);
        end
        WRITE :begin
            if(cnt >= 30) cnt <= 0;
            else cnt <= cnt+1;
            LED_OUT <= 8'b0000_0010;
            if(cnt == 30) state <= DELAY_T;
        end
        CURSOR :begin 
            if(cnt >= 30) cnt <= 0;
            else cnt <= cnt+1;
            LED_OUT <= 8'b0000_0001;
            if(cnt == 30) state <= SET_ADDRESS;
        end
     endcase
  end
end
                              
always @(posedge clk or negedge rst)
begin
    if(!rst)
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0001;
    else begin
        case(state)
            FUNCTION_SET :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0011_1000;
            DISP_ONOFF :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0000_1111;
            ENTRY_MODE :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0000_0110;
            SET_ADDRESS :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0000_0010; // cursor ar home    
            DELAY_T :
                {LCD_RS, LCD_RW, LCD_DATA} = 10'b0_0_0000_1111;    
            WRITE : begin
                if(cnt == 20) begin
                case(number_btn)
                    10'b1000_0000_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1     
                            ccnt <= ccnt+1;
                            end
                    10'b0100_0000_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                             ccnt <= ccnt+1;
                             end
                    10'b0010_0000_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011; // 3
                             ccnt <= ccnt+1;
                             end
                    10'b0001_0000_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100; // 4
                             ccnt <= ccnt+1;
                             end
                    10'b0000_1000_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101; // 5
                             ccnt <= ccnt+1;
                             end
                    10'b1000_0100_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0110; // 6
                             ccnt <= ccnt+1;
                             end
                    10'b1000_0010_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0111; // 7
                             ccnt <= ccnt+1;
                             end
                    10'b1000_0001_00 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1000; // 8
                             ccnt <= ccnt+1;
                             end
                    10'b1000_0000_10 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1001; // 9
                             ccnt <= ccnt+1;
                             end
                    10'b1000_0000_01 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                             ccnt <= ccnt+1;
                             end
                 endcase
              end
              else {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1111;
            end  
             CURSOR : begin
                if(cnt == 20) begin
                       case(control_btn)
                    2'b10 : begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0001_0000; // left  
                             ccnt <= ccnt-1; 
                            end    
                    2'b01 : if(ccnt == 7'b0010101) begin // address가 line1 15지점에 있을때, 오른쪽 쉬프트를 한 상황
                              {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1000_0000; // line1 첫번째 주소로 이동
                              ccnt <= 7'b0000000;
                              end
                            else if(ccnt == 7'b1010101) begin// address가 line2 55지점에 있을때, 오른쪽 쉬프트를 한 상황
                             {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1100_0000; // line 2 첫번쨰 주소로 이동
                             ccnt <=7'b1000000;
                             end
                            else begin {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0001_0100; // 나머지 경우는 오른쪽 shift 실행
                             ccnt <= ccnt+1; 
                            end    
                 endcase
              end
              else {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1111;
            end     
          SET_LINE_1: begin
                 {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1000_0000; // 0위치로 address를 set
            end
          SET_LINE_2: begin               
                 {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1100_0000; // 40위치로 address를 set
            end          
          endcase
      end
  end
  
  assign LCD_E = clk;  
endmodule
