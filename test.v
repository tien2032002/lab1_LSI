module test(reset, flick, clk, out, state, countUp, max, min);
input clk, reset, flick;
output reg [15:0] out;

initial out <= 16'b0;

output reg [15:0] max = 0;
output reg [15:0] min = 0;
output reg countUp = 0;//0 la dem xuong, 1 la dem len

//state
parameter init = 4'b0000,
          s1 = 4'b0001,
          s2 = 4'b0010,
          s3 = 4'b0011,
          s4 = 4'b0100,
          s5 = 4'b0101,
          s6 = 4'b0110,
          s3_flick = 4'b0111,
          s5_flick = 4'b1000,
          kickback5 = 16'b0000_0000_0001_1111,
          kickback10 = 16'b0000_0011_1111_1111;
          
 output reg [3:0] state = init;
 reg [3:0] nextState = init;

//reset block
always @(posedge clk) begin
    if (reset ==1'b0) state <= init;
    else state <=nextState;
end
//update output
always @(posedge clk) begin
    if(countUp==1'b1) out <=out*2+1;
    else out <=out/2;
end

//update state

always @(out, flick) begin
    case (state)
        init: begin
            if (flick == 1) nextState <= s1;
            else nextState <= state;
        end
        s1: begin
            if (out == max) nextState <= s2;
            else nextState <= state;
        end
        s2: begin
            if (out == min) nextState <= s3;
            else nextState <= state;
        end
        s3: begin
            if ((out == kickback5 || out == kickback10) && flick == 1) nextState <= s3_flick;
            else if (out == max) nextState <= s4;
            else nextState <= state;
        end
        s3_flick: begin
            if (out == min) nextState <= s3;
            else nextState <=state;
        end
        s4: begin
            if (out == min) nextState <= s5;
            else nextState <= state;
        end
        s5: begin
            if ((out == kickback5 || out == kickback10) && flick == 1) nextState <= s5_flick;
            else if (out == max) nextState <= s6;
            else nextState <= state;
        end
        s5_flick: begin
            if (out == min) nextState <= s5;
            else nextState <=state;
        end
        s6: begin
            if (out == min) nextState <= init;
            else nextState <= state;
        end
        default: nextState <= state;
    endcase
           
end
//update min,max

always @(state) begin
    case (state)
        init: begin
            min<=0;
            max<=0;
            countUp <= 0;
            end
        s1: begin
            min<=0;
            max<=16'b0000_0000_0001_1111;
            countUp <= 1;
            end
        s2: begin
            min<=0;
            max<=16'b0000_0000_0001_1111;
            countUp <= 0;
            end
        s3: begin
            min<=0;
            max<=16'b0000_0011_1111_1111;
            countUp <= 1;
            end
        s4: begin
            min<=16'b0000_0000_0001_1111;
            max<=16'b0000_0011_1111_1111;
            countUp <= 0;
            end
        s5: 
        begin
            min<=16'b0000_0000_0001_1111;
            max<=16'b1111_1111_1111_1111;
            countUp <= 1;
        end
        s6:
        begin
            min<=0;
            max<=16'b1111_1111_1111_1111;
            countUp <= 0;
        end
        s3_flick:
        begin
            min <=0;
            max <=16'b0000_0000_0001_1111;
            countUp <=0;
        end
        
        s5_flick:
        begin
            min <=16'b0000_0000_0001_1111;
            max <=16'b0000_0011_1111_1111;
            countUp <=0;
        end
        
        default:
        begin
            min<=0;
            max<=0;
            countUp = 0;
        end
    endcase
end

endmodule
        