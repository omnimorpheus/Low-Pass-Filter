`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: UCF_EEL5722C
// Engineer: Syed Ahmed 
// 
// Create Date:    15:02:08 09/28/2015 
// Design Name: 
// Module Name:    vga 
// Project Name: LAB 2 Assignment code is used in LAB5
// Target Devices: VGA monitor 640x480@(25Mhz)
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
input [3:0] char_addr,
input temp_key,
output reg clear_key,
input clock,reset, // the clock signal and the reset push buttons on board
output reg [7:0] red,blue,green,
output reg pixel_clock,hsync, vsync, 
output wire blank,comp_sync
);


assign blank = 1; //initialize the  this signal to 1
assign comp_sync = 1; //initialize the  this signal to 1
// pixel clock = 25Mhz
parameter a = 800; //31.77 * pixel clock 
parameter b = 96;
parameter c = 48;
parameter d = 640;
parameter e = 18;
parameter o = 525; // 16.6 * pixel clock / a
parameter p = 2;
parameter q = 33;
parameter r = 480;
parameter s = 10;

//=====SETTING Pixel Clock @ 25Mhz==============================START=====================
reg [1:0] pcount;
always @ (posedge clock)
begin
	pcount<= pcount+1;
	if (pcount[0]==1)
		pixel_clock <= ~pixel_clock;
	end
//=====SETTING Pixel Clock @ 25Mhz==============================END=======================

//=====Variable Declaration==============================Start=======================
reg [9:0] hsync_count; // the count for the horizontal synchronization signal for 1 cycle || It goes from 0 to 794
reg [9:0] vsync_count; // the count for the vertical synchronization signal for 1 cycle || It goes from 0 to 523
reg web;
reg [3:0] current,next;
reg [8:0] y,yreg,ynxt;
reg [7:0] x,xreg,xnxt;
reg [7:0] current_pixel,cpnxt;
reg [11:0] sum, sumnxt;
wire [15:0] rom_addr1;
reg [15:0] rom_addr;
reg [15:0] rom_addr2;		
wire [15:0] rom_addr_write;
wire [7:0] pixel1; 
wire [7:0] pixel2; 
wire [7:0] pixeltowrite;
wire [10:0] xz;
wire [8:0] yz;
//=====Variable Declaration==============================END=======================

assign rom_addr1 = {yreg,xreg}; // reads the data from ram1...
assign rom_addr_write = {y[7:0],x};// writes the data to both rams...

ram_image image1 // ram1 used to read the pixels (read first then write)
(.clka(pixel_clock), .addra(rom_addr1), .douta(pixel1),
.clkb(pixel_clock), .addrb(rom_addr_write), .dinb(pixeltowrite),.web(web));

ram_image image2 // ram2 used to store the altered pixels after passed thru the LPF (read first then write)
(.clka(pixel_clock), .addra(rom_addr2), .douta(pixel2),
.clkb(pixel_clock), .addrb(rom_addr_write), .dinb(pixeltowrite),.web(web));
  

always @(posedge pixel_clock) 
begin
    rom_addr <= xz[7:0] * 256 + yz[7:0];
end

//=====Initialization==============================Start=======================  
initial
begin
hsync_count<=0;
vsync_count<=0;
pixel_clock<=0;
web<=0;
end
//=====Initialization==============================END=======================
always @ (posedge pixel_clock) // When the clock ticks
begin
	hsync_count <= hsync_count + 1; // keep counting buddy and keep up the good work ;)
	// the value for hsync and vsynce is either 1 or 0 and this is output from the board and input to the vga monitor
	// lets now handle this value within each cycle
	//============== Determine the horizontal and vertical synchronization values ===========START======
	//============== At the begining of the cycle =================== START =========
	if (hsync_count >= a)  // when the limit of one cycle is reached
		begin
			hsync_count <= 0; // reset the count value so that it can start from 0 for the next cycle
			vsync_count <= vsync_count + 1; // now start counting in y axis i.e for the vertical sync signal.
		end
	if (vsync_count >= o) // this is alphabet o and not zero ||  when the limit of one cycle is reached
		begin
		vsync_count <= 0; // reset the count value so that it can start from 0 for the next cycle
		end
	//============== At the begining of the cycle =================== END =========
	
	//============== turn on the synchronization signals ==================== Start =========
	if ((vsync_count >= p) && (vsync_count < o))
			begin
			vsync <= 1;
			end
	else
			begin
			vsync <= 0;
			end
	if ((hsync_count >= b) && (hsync_count < a))
			begin
			hsync <= 1;
			end
	else
			begin
			hsync <= 0;
			end
	//============== turn on the synchronization signals ==================== End =========
	
	//============== handle c,d,e ==================== Start =========
if ((hsync_count >= b+c) && (hsync_count < a-e)) // inside 640x480
	begin
		if ((hsync_count > b+c+112)&&(hsync_count <b+c+368)&&(vsync_count > p+q+221)&&(vsync_count < p+q+477)) // inside 8x8 square
			begin
				red <= pixel1;green <= pixel1;blue <= pixel1; // pixel value
			end
		else
			begin
			red <= 0;green <= 0;blue <= 0; // outside 8x8 but inside 640x480
			end
	end
else // outside 640x480
	begin
		red <= 0;green <= 0;blue <= 0;
	end
//============== handle c,d,e ==================== end =========
end //=======When the clock ticks=====end========

//========================= capturing the values of the neighbouring pixels============ Start ================
always @(x, y, current_pixel) begin
    case (current_pixel)
        0: begin
            xreg = x;
            yreg = y[7:0];
        end
        1: begin
            xreg = x-1;
            yreg = y[7:0];
        end
        2: begin
            xreg = x+1;
            yreg = y[7:0];
        end
        3: begin
            xreg = x;
            yreg = y[7:0]-1;
        end
        4: begin
            xreg = x-1;
            yreg = y[7:0]-1;
        end
        5: begin
            xreg = x+1;
            yreg = y[7:0]-1;
        end
        6: begin
            xreg = x;
            yreg = y[7:0]+1;
        end
        7: begin
            xreg = x-1;
            yreg = y[7:0]+1;
        end
        8: begin
            xreg = x+1;
            yreg = y[7:0]+1;
        end
        default: begin
            xreg = x;
            yreg = y[7:0];
        end
    endcase
end
//========================= capturing the values of the neighbouring pixels============ End ================

always @(posedge pixel_clock) begin // defining the flow of states based on clock
    current <= next;
end

//=====Variable Declaration==============================Start=======================  
reg read;
reg write;
reg [7:0] mem_in;
reg [7:0] ram_output;
assign web0 = ~write & web;
assign web1 = write & web;
assign pixeltowrite = ram_output;
//=====Variable Declaration==============================END=======================  

always @(posedge pixel_clock) begin // When the state changes, the attributes also change at the same clock....
	sum <= sumnxt;
    x <= xnxt;
	y <= ynxt;
	current_pixel <= cpnxt;
end

reg [15:0] temp1;
reg [15:0] temp2;


always @(rom_addr1,read,rom_addr) 
begin
    if (read)
      rom_addr2 = rom_addr1; 
    else
	  rom_addr2 = rom_addr;
end

always @(read, pixel1, pixel2) 
begin
    if (read)
        mem_in = pixel1;
    else
        mem_in = pixel2;
end


always @(temp_key,char_addr,current,x,y, current_pixel) begin
    case (current)
        0: next = 1; // the state waits for us to press the keyboard key....
        1: 
		begin
		if (temp_key)
                next = 2; // when the key is pressed we move to the next state else we keep waiting....
            else
                next = 1; // keep waiting if the key is not pressed....
        end
		2: begin
				if (char_addr == 4'b0000) // if '0' key is pressed....
					next = 3; // move to next state
				else
					next = 2; // key waiting until '0' key is pressed
			end
        3: next = 4; // this state depends on other instance occurrence and hence is defined later
        4: begin
            if (x > 0 && y < 256) // when reached the display area....
                next = 8;
            else
                next = 5;
        end
        5: next = 6;		// Defined 
		6: next = 7;		// in 
		7: next = 8;		// later 
		8: next = 9;		// stage...
        9: begin
            if (x == 0 && y == 256)
                next = 1;
            else
                next = 10;
        end
        10: begin
            if (current_pixel == 9) // when all the neighbour pixels have been altered
                next = 14;
            else
                next = 11;
        end
        11: next = 12;        // Defined 
		12: next = 13;        // in 
		13: next = 14;        // later 
		14: next = 15;        // stage...
		15: next = 9;
        default: next = 0;
    endcase
end


always @(current, mem_in, sum, x, y, current_pixel) 
begin
	read = 0;					//
	write = 0;					//
	web = 0;					//
	ram_output = 0;         	//
	sumnxt = sum;				// Initialization
	xnxt = x;					//
	ynxt = y;					//
	cpnxt = current_pixel;		//
	clear_key = 0;				//

    case (current)
        2: clear_key = 1; // After the key is pressed....
		3:
		begin //reset the counters for neighbouring pixels.... 
			xnxt = 0;
			ynxt = 0;
			cpnxt = 0;
		end
        5: //copying from one ram to ANOTHER
		read = 1; 
		6:
		begin // WRITING THE COPIED PIXEL VALUES....
			read = 1;
			write = 0;
			web = 1;
			ram_output = mem_in;
		end
		7:
		begin // moving towards the next block to be fed to LPF
			if (x == 255) 
				begin
				xnxt = 0;
				ynxt = ynxt + 1;
				end
			else 
				begin
				xnxt = xnxt + 1;
				end
		end
		8:
		begin
			xnxt = 0;
			ynxt = 0;
			cpnxt = 0;
			sumnxt = 0;
		end
        11: read = 0;
        12: 
		begin
			read = 0;
			sumnxt = sum + {4'b0000, mem_in};
		end
        13: 
		begin
		    cpnxt = current_pixel + 1;
		end
        14: 
		begin
			write = 1;
			web = 1;
			ram_output = (sum >> 6) + (sum >> 5) + (sum >> 4); //dividing the sum by approx. 9 where as its actually 9.142
		end
        15: 
		begin
			cpnxt = 0; //moving to the next block
			if (x == 255) 
				begin
				xnxt = 0;
				ynxt = y + 1;
				end
			else 
				begin
				xnxt = xnxt + 1;
				end
			sumnxt = 0;
		end
        default: 
		begin
		end
	endcase
end



endmodule
