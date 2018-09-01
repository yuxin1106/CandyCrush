`timescale 1ns / 1ps
/* 
File: Candy Crush Simple State Machine
Author: Xin Yu
*/

// 8 x 8 screen, 6 colors
// [2:0]a[8i+j] = [2:0]a[8Y+X]  for test bench

module CandyCrush_Simple(
      // inputs
      Clk, Reset, BtnC, BtnL, BtnR, BtnU, BtnD,
      ColorXY,
		Enable,
      // outputs (to be continued)
      rewriteX, rewriteY, X, Y, swapX, swapY,
      randFlag, swapFlag,
      stateNum
    );

// declare signals 
input BtnC, BtnL, BtnR, BtnU, BtnD, Clk, Reset;
input [2:0] ColorXY;                               // 6 colors
input Enable;                                      // enable candy crush
output reg [2:0] rewriteX, rewriteY;               // assign coordinates of places to be filled in with random color
output reg [2:0] X, Y; 
output reg [2:0] swapX, swapY;                     // candy to swap with current X, Y
output reg randFlag, swapFlag;                     // indicate when to swap or write random
output reg [3:0] stateNum;

// intermediate signals
reg [2:0] columnSlidesCount [7:0];                 // save how many places to slide down in each column
reg [2:0] columnSlidesStart [7:0];                 // save the Y-coordinate from which to slide down
reg [2:0] colorSaved;                              // save the color of the candy chosen by the user
reg [2:0] firstX, firstY;                          // coordinate of the candy chosen by the user
reg UpFlag, DownFlag, RightFlag, LeftFlag;         // check four directions
reg firstSlidedFlag;                               // if there is any 
reg [12:0] state;                                  // hold states
reg [3:0] indexCtr, slidesCtr;                     // counter to increment index of columnSlidesCount & columnSlidesStart
                                                   // counter to decrement columnSlidesStart

localparam
InitialVar = 13'b0000000000001,
SelectFirst = 13'b0000000000010,
SelectSecond = 13'b0000000000100,
SwapColor = 13'b0000000001000,
CheckAround = 13'b0000000010000,
UpCheck = 13'b0000000100000,
DownCheck = 13'b0000001000000,
RightCheck = 13'b0000010000000,
LeftCheck = 13'b0000100000000,
ColumnCheck = 13'b0001000000000,
SlideDown = 13'b0010000000000,
FillRand = 13'b0100000000000,
ResetValues = 13'b1000000000000;

// for SSD
always @(posedge Clk)
begin 
   case(state)
       InitialVar:    stateNum = 4'b0001;
       SelectFirst:   stateNum = 4'b0010;
       SelectSecond:  stateNum = 4'b0011;
       SwapColor:    stateNum = 4'b0100;
       CheckAround:    stateNum = 4'b0101;
       UpCheck:       stateNum = 4'b0110;
       DownCheck:     stateNum = 4'b0111;
       RightCheck:    stateNum = 4'b1000;
       LeftCheck:     stateNum = 4'b1001;
       ColumnCheck:    stateNum = 4'b1010;
       SlideDown:   stateNum = 4'b1011;
       FillRand:     stateNum = 4'b1100;
       ResetValues:     stateNum = 4'b1101;
    endcase
end

// state machine diagram
always @(posedge Clk)
begin
     if (Reset)
     begin
        state <= InitialVar;
        X <= 3'bXXX;
        Y <= 3'bXXX;
        firstX <= 3'bXXX;
        firstY <= 3'bXXX;
       
        UpFlag <= 1'b0;
        DownFlag <= 1'b0;
        RightFlag <= 1'b0;
        LeftFlag <= 1'b0;
        firstSlidedFlag <= 1'b0;
        
        rewriteX <= 3'bXXX;
        rewriteY <= 3'bXXX;
        swapX <= 3'bXXX;
        swapY <= 3'bXXX;
       
        randFlag <= 1'b0;
        swapFlag <= 1'b0;
     
        colorSaved <= 3'bXXX;
        indexCtr <= 4'b0000;
        // to be continued
     end
     else if (Enable)
     begin
        case (state)
        InitialVar:
        begin
          state <= SelectFirst;
          
          X <= 3;
          Y <= 3;
          firstX <= 3'b000;
          firstY <= 3'b000;
           
          rewriteX <= 3'b000;
          rewriteY <= 3'b000;
          swapX <= 3'b000;
          swapY <= 3'b000;
          
          colorSaved <= 3'b000;
            
          columnSlidesCount[0] <= 3'b000; 
		  columnSlidesCount[1] <= 3'b000;
		  columnSlidesCount[2] <= 3'b000;
		  columnSlidesCount[3] <= 3'b000;
		  columnSlidesCount[4] <= 3'b000;
		  columnSlidesCount[5] <= 3'b000;
		  columnSlidesCount[6] <= 3'b000;
		  columnSlidesCount[7] <= 3'b000;
	   
		  columnSlidesStart[0] <= 3'b000;
		  columnSlidesStart[1] <= 3'b000;
		  columnSlidesStart[2] <= 3'b000;
		  columnSlidesStart[3] <= 3'b000;
		  columnSlidesStart[4] <= 3'b000;
		  columnSlidesStart[5] <= 3'b000;
		  columnSlidesStart[6] <= 3'b000;
		  columnSlidesStart[7] <= 3'b000;
        
        end
        SelectFirst:
        begin
          if (BtnC)
          begin
             state <= SelectSecond;
             
             firstX <= X;
             firstY <= Y;
             colorSaved <= ColorXY;
          end
          else if (BtnU)
          begin
             if (Y > 0)
                Y <= Y - 1;
          end
          else if (BtnD)
          begin
             if (Y < 7)
                Y <= Y + 1;
          end
          else if (BtnR)
          begin
             if (X < 7)
                X <= X + 1;
          end
          else if (BtnL)
             if (X > 0)
                X <= X - 1;
          begin
          end
        
        end
        SelectSecond:
        begin
          if (BtnU|BtnD|BtnR|BtnL)
          begin
             state <= SwapColor;
             
             swapX <= firstX;
             swapY <= firstY;
             
             swapFlag <= 1;    // after clock, can perform swap color
             
             if (BtnU)
             begin
               if (Y > 0)
                  Y <= Y - 1;
             end
             else if (BtnD)
             begin
			   if (Y < 7)
				  Y <= Y + 1;
             end
             else if (BtnR)
             begin
               if (X < 7)
                  X <= X + 1;
             end
             else if (BtnL)
               if (X > 0)
                  X <= X - 1;
             begin
             end
          end
        end
        SwapColor:
        begin
           state <= CheckAround;
           swapFlag <= 0;
           // set back to the coordinate of first candy
          // X <= firstX;
          // Y <= firstY;
			  // update first candy coordinates after swap
           firstX <= X;
           firstY <= Y;
        end
        CheckAround:
        begin
           if (!UpFlag)
           begin
              UpFlag <= 1;
              if (Y > 0)
              begin
                 state <= UpCheck;
                 Y <= Y - 1;
              end
           end
           else if (!DownFlag)
           begin
              DownFlag <= 1;
              if (Y < 7)
              begin
                 state <= DownCheck;
                 Y <= Y + 1;
              end
           end
           else if (!RightFlag)
           begin
              RightFlag <= 1;
              if (X < 7)
              begin
                 state <= RightCheck;
                 X <= X + 1;
              end
           end
           else if (!LeftFlag)
           begin
              LeftFlag <= 1;
              if (X > 0)
                 state <= LeftCheck;
                 X <= X - 1;
           end
           else
           begin 
              //columnSlidesCount[firstX] <= columnSlidesCount[firstX] + 1;
              state <= ColumnCheck;
              if (firstSlidedFlag)
              begin
                 columnSlidesCount[firstX] <= columnSlidesCount[firstX] + 1;
                 if (columnSlidesStart[firstX] < firstY)
                     columnSlidesStart[firstX] <= firstY;
              end
           end
           
        end
        UpCheck:
        begin
            if (ColorXY == colorSaved)
            begin
               firstSlidedFlag <= 1;
               columnSlidesCount[firstX] <= columnSlidesCount[firstX] + 1;
               if (columnSlidesStart[firstX] < Y)
                   columnSlidesStart[firstX] <= Y;
               
               if (Y > 0)
                  Y <= Y - 1;
               else
               begin
                  state <= CheckAround;
                  Y <= firstY;
               end
            end
            else
            begin
               state <= CheckAround;
               Y <= firstY;
            end
        end
        DownCheck:
        begin
            if (ColorXY == colorSaved)
            begin
               firstSlidedFlag <= 1;
               columnSlidesCount[firstX] <= columnSlidesCount[firstX] + 1;
               columnSlidesStart[firstX] <= Y;
               
               if (Y < 7)
                  Y <= Y + 1;
               else
               begin
                  state <= CheckAround;
                  Y <= firstY;
               end
            end
            else
            begin
               state <= CheckAround;
               Y <= firstY;
            end
            
        end
        RightCheck:
        begin
            if (ColorXY == colorSaved)
            begin
                firstSlidedFlag <= 1;
                columnSlidesCount[X] <= columnSlidesCount[X] + 1;
                columnSlidesStart[X] <= firstY;
                
                if (X < 7)
                   X <= X + 1;
                else
                begin
                  state <= CheckAround;
                  X <= firstX;
                end
            end
            else
            begin
               state <= CheckAround;
               X <= firstX;
            end
        end
        LeftCheck:
        begin
            if (ColorXY == colorSaved)
            begin
               firstSlidedFlag <= 1;
               columnSlidesCount[X] <= columnSlidesCount[X] + 1;
               columnSlidesStart[X] <= firstY;
               
               if (X > 0)
                  X <= X - 1;
               else
               begin
                  state <= CheckAround;
                  X <= firstX;
               end
            end
            else
            begin
              state <= CheckAround;
              X <= firstX;
            end
        end
        ColumnCheck:
        begin
           // to be continued
           if (indexCtr == 8)
              state <= ResetValues;
           else
           begin
              if (columnSlidesCount[indexCtr] != 0)
              begin
                 state <= SlideDown;
                 
                 swapY <= columnSlidesStart[indexCtr];
                 swapX <= indexCtr;
                 if (columnSlidesStart[indexCtr] > columnSlidesCount[indexCtr])					  
                     Y <= columnSlidesStart[indexCtr] - columnSlidesCount[indexCtr];
					  else
					      Y <= 0;
                 X <= indexCtr;
					  swapFlag <= 1;
              end
              else 
                 indexCtr <= indexCtr + 1;
           end
           
        end
        SlideDown:
        begin
           //swapFlag <= 1;
			  if (swapY > 0)
               swapY <= swapY - 1;
			  if (Y > 0)
               Y <= Y - 1;
           if (Y == 0)
           begin
              state <= FillRand;
              
              rewriteX <= indexCtr;
              rewriteY <= 0;
              slidesCtr <= columnSlidesCount[indexCtr] - 1;
				  swapFlag <= 0;
				  randFlag <= 1;
           end
        end
        FillRand:
        begin
          // swapFlag <= 0;
           if (slidesCtr != 0)
           begin
              randFlag <= 1;
              rewriteY <= rewriteY + 1;
              
              slidesCtr <= slidesCtr - 1;
           end
           else
           begin
              state <= ColumnCheck;
              
              randFlag <= 0;
              indexCtr <= indexCtr + 1;
           end
        end
        ResetValues:
        begin
           state <= SelectFirst;
           
           X <= firstX;
           Y <= firstY;
           colorSaved <= 3'b000;
           
           rewriteX <= 3'b000;
           rewriteY <= 3'b000;
           swapX <= 3'b000;
           swapY <= 3'b000;
           
		   columnSlidesCount[0] <= 3'b000; 
		   columnSlidesCount[1] <= 3'b000;
		   columnSlidesCount[2] <= 3'b000;
		   columnSlidesCount[3] <= 3'b000;
		   columnSlidesCount[4] <= 3'b000;
		   columnSlidesCount[5] <= 3'b000;
		   columnSlidesCount[6] <= 3'b000;
		   columnSlidesCount[7] <= 3'b000;
   
		   columnSlidesStart[0] <= 3'b000;
		   columnSlidesStart[1] <= 3'b000;
		   columnSlidesStart[2] <= 3'b000;
		   columnSlidesStart[3] <= 3'b000;
		   columnSlidesStart[4] <= 3'b000;
		   columnSlidesStart[5] <= 3'b000;
		   columnSlidesStart[6] <= 3'b000;
		   columnSlidesStart[7] <= 3'b000;
		   
		   UpFlag <= 0;
		   DownFlag <= 0;
		   RightFlag <= 0;
		   LeftFlag <= 0;
		   firstSlidedFlag <= 0;
		   
		   indexCtr <= 0;
		   slidesCtr <= 0;
		      
           
        end
        
       endcase
     end

end


endmodule
