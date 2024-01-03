`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/17 12:25:41
// Design Name: 
// Module Name: Top
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


module Top(
	input clk,
	input rstn,
	input [15:0]SW,
	inout[4:0] BTN_X,
	inout[3:0] BTN_Y,
	output hs,
	output vs,
	output [3:0] r,
	output [3:0] g,
	output [3:0] b,
	input ps2_clk,
	input ps2_data
    );
	
	reg [31:0]clkdiv;
	always@(posedge clk) begin
		clkdiv <= clkdiv + 1'b1;
	end
	wire [15:0] SW_OK;
AntiJitter #(4) a0[15:0](.clk(clkdiv[15]),.I(SW),.O(SW_OK));//防抖动
	wire [31:0] segTestData;
	wire [3:0]sout;
 	reg [11:0] vga_data;
	wire [11:0] spob;
	wire [11:0] spom1;
	wire [11:0] spom2;
	wire [11:0] spom3;
	wire [11:0] spomr1;
	wire [11:0] spomr2;
	wire [11:0] spomgo;
	wire [11:0] spomt1;
	wire [11:0] spomt2;
 	wire [9:0] col_addr;
 	wire [8:0] row_addr;
	vgac v0 (
		.vga_clk(clkdiv[1]), .clrn(SW_OK[0]), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(r), .g(g), .b(b), .hs(hs), .vs(vs)
	);
	wire[9:0] ps2_dataout;
	wire ps2_ready;
	PS2_keyboard ps2(.clk(clk), .rst(SW_OK[15]), .ps2_clk(ps2_clk), 
							.ps2_data(ps2_data), .data_out(ps2_dataout), .ready(ps2_ready));
	wire[4:0] keyCode;
	wire keyReady;
	Keypad k0(.clk(clkdiv[15]), .keyX(BTN_Y), .keyY(BTN_X), .keyCode(keyCode), .ready(keyReady));	//BTN矩阵模式防抖
//定义变量地址，以及下x,y坐标
	reg [18:0] bg1;
	reg [18:0] mar;
	reg [18:0] mr;
	reg [18:0] go1;
	reg [18:0] ttl;
	reg [9:0] mario_x;
	reg [8:0] mario_y;
	reg loadmario1;
	reg loadmario2;
	reg loadmario3;
	reg loadmushroom1;
	reg loadturtle1;
	//reg [18:0] mushroom1;
	reg [9:0] mushroom_x;
	reg [8:0] mushroom_y;
	//reg [18:0] mushroom;
	
	//reg [9:0] mushroom2_x;
	//reg [8:0] mushroom2_y;
	//reg [18:0] turtle1;
	reg [9:0] turtle_x;
	reg [8:0] turtle_y;
	//reg [9:0] turtle2_x;
	//reg [8:0] turtle2_y;
	//reg [18:0] turtle2;
	reg cover;//定义是否为封面
	reg overgame;
	reg wasReady;
	reg ishit;
	reg life=3;
	reg isJump;
   reg blood_x ;   reg blood_x1;   reg blood_x2;
   reg blood_y;
	reg[7:0] jumpTime;	//跳跃时间计数器
	initial isJump <= 1'b0;
	initial cover<=1;
	initial overgame<=0;
	initial mario_x=100;
	initial mario_y=200;
   initial mushroom_x=480;
	initial mushroom_y=300;
	initial life=3;
	initial loadmario1=1;
	initial loadmario2=0;
	initial loadmario3=0;
	initial loadmushroom1=1;
	initial loadturtle1=1;
	initial begin
blood_x = 65;blood_x1 =85;blood_x2 =105;
blood_y = 410;
end
	always @(posedge clk) begin
	bg1<=(col_addr>=0&&col_addr<=639&&row_addr>=0&&row_addr<=479)?(480-row_addr)*640+col_addr:0;
	mar<=(col_addr>=mario_x&&col_addr<=mario_x+49&&row_addr>=mario_y&&row_addr<=mario_y+99)?(100-(row_addr-mario_y))*50+(col_addr-mario_x):0;
	go1<=(col_addr>=0&&col_addr<=639&&row_addr>=0&&row_addr<=479)?(480-row_addr)*640+col_addr:0;
	mr<=(col_addr>=mushroom_x&&col_addr<=mushroom_x+59&&row_addr>=mushroom_y&&row_addr<=mushroom_y+59)?(60-(row_addr-mushroom_y))*60+(col_addr-mushroom_x):0;
	ttl<=(col_addr>=turtle_x&&col_addr<=turtle_x+59&&row_addr>=turtle_y&&row_addr<=turtle_y+79)?(80-(row_addr-turtle_y))*60+(col_addr-turtle_y):0;
	end
	background b1(.addra(bg1),.douta(spob),.clka(clkdiv[1]));
	mario1 m1(.addra(mar),.douta(spom1),.clka(clkdiv[1]));
	mario2 m2(.addra(mar),.douta(spom2),.clka(clkdiv[1]));
	mario3 m3(.addra(mar),.douta(spom3),.clka(clkdiv[1]));
	mushroom1 m4(.addra(mr),.douta(spomr1),.clka(clkdiv[1]));
	mushroom2 m5(.addra(mr),.douta(spomr2),.clka(clkdiv[1]));
	gameover go(.addra(go1),.douta(spomgo),.clka(clkdiv[1]));
	turtle1 t1(.addra(ttl),.douta(spomt1),.clka(clkdiv[1]));
	turtle2 t2(.addra(ttl),.douta(spomt2),.clka(clkdiv[1]));
	
	always @(posedge clk) begin
	if(col_addr>=0&&col_addr<=640&&row_addr>=0&&row_addr<=480&&!overgame) begin
       vga_data <= spob[11:0];
end
    if(col_addr>=mario_x && col_addr<=mario_x+49&& row_addr>=mario_y && row_addr<=mario_y+99&&!overgame) begin
	 if(loadmario1&&!loadmario2&&!loadmario3)begin
			if(spom1[11:0]!=12'hfff)begin
        vga_data <= spom1[11:0]; end
		  end
	 else if(!loadmario1&&loadmario2&&!loadmario3) begin
		 if(spom2[11:0]!=12'hfff)begin
        vga_data <= spom2[11:0]; end
		  end
	 else if(!loadmario1&&!loadmario2&&loadmario3)begin
		 if(spom3[11:0]!=12'hfff)begin
        vga_data <= spom3[11:0]; end
		  end
    end
	 if (col_addr>=mushroom_x&&col_addr<=mushroom_x+59&&row_addr>=mushroom_y&&row_addr<=mushroom_y+59&&!overgame) begin
		if(loadmushroom1&&spomr1[11:0]!=12'hfff)	begin	vga_data<=spomr1[11:0];end
		else if(!loadmushroom1&&spomr2[11:0]!=12'hfff) begin vga_data<=spomr2[11:0];end
	 end
	if(overgame) begin
		if(col_addr>=0&&col_addr<=639&&row_addr>=0&&row_addr<=479) begin
		vga_data <= spomgo[11:0]; 
		end
	end
end
always @(posedge clk) begin
		if(!wasReady && keyReady)begin
			case(keyCode)
				5'h10: if(jumpTime >= 8'd64)begin isJump <= 1'b1; jumpTime <= 8'd0; end	//开始跳跃，将计数器置零
				default:;
			endcase
		end
		if(ps2_dataout[7:0]==8'h12 && ps2_ready)//左shift
			if(jumpTime >= 8'd64)begin isJump <= 1'b1; jumpTime <= 8'd0; end
	
	if(clkdiv[24]&&!overgame) begin
	loadmario1=1;
	loadmario2=0;
	loadmario3=0;end
	else if(!clkdiv[23]&&!clkdiv[24]&&!overgame) begin
	loadmario1=0;
	loadmario2=1;
	loadmario3=0;
	end
	else if(!overgame) begin
	loadmario1=0;
	loadmario2=0;
	loadmario3=1;
	end
	if(clkdiv[23]&&!overgame) begin
		loadmushroom1=0;
	end
	else if(!clkdiv[23]&&!overgame) begin
		loadmushroom1=1;
	end
	if(clkdiv[23]&&!overgame) begin
		loadturtle1=1;
	end
	else if(!clkdiv[23]&&!overgame) begin
		loadturtle1=0;
	end
	//注：上升/下降均采用分三段速度进行，模拟重力
		//跳跃上升阶段开始
		if(clkdiv[19] && isJump && jumpTime < 8'd10)begin
			mario_y <= mario_y - 10'd6;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		if(clkdiv[19] && isJump && jumpTime >= 8'd10 && jumpTime < 8'd20)begin
			mario_y <= mario_y - 10'd4;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		if(clkdiv[19] && isJump && jumpTime >= 8'd20 && jumpTime < 8'd32)begin
			mario_y <= mario_y - 10'd2;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		//跳跃上升阶段结束
		else if(!clkdiv[19] && !isJump && jumpTime < 8'd64) begin
			isJump <= 1;
		end
		//跳跃下降阶段开始
		if(clkdiv[19] && isJump && jumpTime >= 8'd32 && jumpTime < 8'd44)begin
			mario_y <= mario_y + 10'd2;
			jumpTime <= jumpTime + 8'd1;
			isJump <= 0;
		end
		if(clkdiv[19] && isJump && jumpTime >= 8'd44 && jumpTime < 8'd54)begin
			mario_y <= mario_y + 10'd4;
			jumpTime <= jumpTime + 8'd1;
			isJump <= 0;
		end
		if(clkdiv[19] && isJump && jumpTime >= 8'd54 && jumpTime < 8'd64)begin
			mario_y <= mario_y + 10'd6;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		//跳跃下降阶段结束
end
always @(*) begin
	if(mario_x+50>=mushroom_x&&mario_x+50<=mushroom_x+60&&mario_y+100<=mushroom_y
	||mario_x+50>=mushroom_x+60&&mario_x<=mushroom_x+60&&mario_y+100<=mushroom_y
	) ishit=1;
	//if(mario_x+25>=turtle_x&&mario_x+25<=turtle_x+30&&mario_y+50<=turtle_y
	//||mario_x+25>=turtle_x+30&&mario_x<=turtle_x+30&&mario_y+50<=turtle_y
	//) ishit=1;	
	if(ishit) begin
		//gameover=1;
		life=life-1;
		end
	if (life==0) overgame=1;
	
end
endmodule
