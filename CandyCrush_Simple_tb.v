/*
File: Candy Crush Simple State Machine Test bench
Author: Xin Yu
*/

`timescale 1ns / 1ps

module CandyCrush_Simple_tb;

// inputs
reg Clk;
reg Reset;
reg BtnC;
reg BtnL;
reg BtnR;
reg BtnU;
reg BtnD;
reg[2:0] c[63:0];         // candies[X][Y] = candies[8*Y+X]

// outputs
wire[2:0] X;
wire[2:0] Y;
wire[2:0] rewriteX;
wire[2:0] rewriteY;
wire[2:0] swapX;
wire[2:0] swapY;
wire randFlag;
wire swapFlag;
wire[3:0] stateNum;


// Instantiate the Unit Under Test (UUT)
CandyCrush_Simple uut (
      // inputs
      .Clk(Clk), 
      .Reset(Reset), 
      .BtnC(BtnC), 
      .BtnL(BtnL), 
      .BtnR(BtnR), 
      .BtnU(BtnU), 
      .BtnD(BtnD),
      .ColorXY(c[8*Y+X]),
		.Enable(1'b1),
      // outputs 
      .rewriteX(rewriteX), 
      .rewriteY(rewriteY), 
      .X(X), 
      .Y(Y), 
      .swapX(swapX), 
      .swapY(swapY),
      .randFlag(randFlag), 
      .swapFlag(swapFlag),
      .stateNum(stateNum)
);


initial
	   begin: CLOCK_GENERATOR
		 Clk = 0;
		 forever
		    begin
			    #5 Clk = ~Clk;
			 end
		 end
		 
initial begin
     // Initialize Inputs
		Clk = 0;
		Reset = 0;

        // candies
        // 0: blue, 1: red, 2: yellow, 3: purple, 4: green, 5: orange
        
        // o p r g y o y y         5 3 1 4 2 5 2 2
        // b r y p y y g o         0 1 2 3 2 2 4 5
        // o p r p o p b r         5 3 1 3 5 3 0 1
        // p g p o r b o r         3 4 3 5 1 0 5 1
        // r g b r o r b o         1 4 0 1 5 1 0 5
        // r y o y b o r r         1 2 5 2 0 5 1 1
        // y o y b g y p o         2 5 2 0 4 2 3 5
        // y g r y p o o g         2 4 1 2 3 5 5 4
        
       /* c[63]=3'b101;c[62]=3'b011;c[61]=3'b001;c[60]=3'b100;c[59]=3'b010;c[58]=3'b101;c[57]=3'b010;c[56]=3'b010;
        c[55]=3'b000;c[54]=3'b001;c[53]=3'b010;c[52]=3'b011;c[51]=3'b010;c[50]=3'b010;c[49]=3'b100;c[48]=3'b101;
        c[47]=3'b101;c[46]=3'b011;c[45]=3'b001;c[44]=3'b011;c[43]=3'b101;c[42]=3'b011;c[41]=3'b000;c[40]=3'b001;
        c[39]=3'b011;c[38]=3'b100;c[37]=3'b011;c[36]=3'b101;c[35]=3'b001;c[34]=3'b000;c[33]=3'b101;c[32]=3'b001;
        c[31]=3'b001;c[30]=3'b100;c[29]=3'b000;c[28]=3'b001;c[27]=3'b101;c[26]=3'b001;c[25]=3'b000;c[24]=3'b101;
        c[23]=3'b001;c[22]=3'b010;c[21]=3'b101;c[20]=3'b010;c[19]=3'b000;c[18]=3'b101;c[17]=3'b001;c[16]=3'b001;
        c[15]=3'b010;c[14]=3'b101;c[13]=3'b010;c[12]=3'b000;c[11]=3'b100;c[10]=3'b010;c[9]=3'b011;c[8]=3'b101;
        c[7]=3'b010;c[6]=3'b100;c[5]=3'b001;c[4]=3'b010;c[3]=3'b011;c[2]=3'b101;c[1]=3'b101;c[0]=3'b100;*/
		  
		  
		  c[0]=3'b101;c[1]=3'b011;c[2]=3'b001;c[3]=3'b100;c[4]=3'b010;c[5]=3'b101;c[6]=3'b010;c[7]=3'b010;
        c[8]=3'b000;c[9]=3'b001;c[10]=3'b010;c[11]=3'b011;c[12]=3'b010;c[13]=3'b010;c[14]=3'b100;c[15]=3'b101;
        c[16]=3'b101;c[17]=3'b011;c[18]=3'b001;c[19]=3'b011;c[20]=3'b101;c[21]=3'b011;c[22]=3'b000;c[23]=3'b001;
        c[24]=3'b011;c[25]=3'b100;c[26]=3'b011;c[27]=3'b101;c[28]=3'b001;c[29]=3'b000;c[30]=3'b101;c[31]=3'b001;
        c[32]=3'b001;c[33]=3'b100;c[34]=3'b000;c[35]=3'b001;c[36]=3'b101;c[37]=3'b001;c[38]=3'b000;c[39]=3'b101;
        c[40]=3'b001;c[41]=3'b010;c[42]=3'b101;c[43]=3'b010;c[44]=3'b000;c[45]=3'b101;c[46]=3'b001;c[47]=3'b001;
        c[48]=3'b010;c[49]=3'b101;c[50]=3'b010;c[51]=3'b000;c[52]=3'b100;c[53]=3'b010;c[54]=3'b011;c[55]=3'b101;
        c[56]=3'b010;c[57]=3'b100;c[58]=3'b001;c[59]=3'b010;c[60]=3'b011;c[61]=3'b101;c[62]=3'b101;c[63]=3'b100;

		// Wait 100 ns for global reset to finish
		#100;
		
		candycrush;

end
 
task candycrush;
begin
        Reset = 1;
		@(posedge Clk);
		#5;
		Reset = 0;
		@(posedge Clk);
		#5;
		BtnU = 0;
		BtnD = 0;
		BtnR = 0;
		BtnL = 0;
		BtnC = 0;
		
		#12;
		
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		BtnL = 1;
		#5;
		BtnL = 0;
		#5;
		
		BtnC = 1;
		#5;
		BtnC = 0;
		#5;
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		#400;     // wait for test 1 to finish
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnL = 1;
		#5;
		BtnL = 0;
		#5;
		
		BtnL = 1;
		#5;
		BtnL = 0;
		#5;
		
		BtnC = 1;
		#5;
		BtnC = 0;
		#5;
		
		BtnL = 1;
		#5;
		BtnL = 0;
		#5;
		
		#400;     // wait for test 2 to finish
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
      BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		BtnC = 1;
		#5;
		BtnC = 0;
		#5;
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		#400;     // wait for test 3 to finish
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		BtnR = 1;
		#5;
		BtnR = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnD = 1;
		#5;
		BtnD = 0;
		#5;
		
		BtnC = 1;
		#5;
		BtnC = 0;
		#5;
		
		BtnU = 1;
		#5;
		BtnU = 0;
		#5;
		
		#400;     // wait for test 4 to finish
		
end
endtask		 
		 
		 
		 
		 
endmodule










  