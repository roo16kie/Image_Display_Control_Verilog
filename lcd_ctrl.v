module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  [7:0]   dataout;
output          output_valid;
output          busy;

//parameter
parameter  IDLE = 2'b00 ;
parameter  LOAD = 2'b01 ;
parameter   OP  = 2'b11 ;
parameter  OUT  = 2'b10 ;

//reg
reg  [1:0] state_ns =2'b00 , state_cs =2'b00 ;
reg  [7:0] in_buffer [0:35]  ;
reg  [7:0] out_buffer [0:8]  ;
reg  [3:0] count ;
reg  [6:0] counter = 6'd0 ;
reg        tag_op1 = 0 ;
reg        tag_out = 0 ;
reg        tag_idle = 0 ;
reg  [6:0] record = 6'd0 ;
reg        output_valid ;
reg  [7:0] dataout ;



//wire
wire LOAD_sig ;
wire OP0_sig  ;
wire OP1_sig  ;
wire OP2_sig  ;
wire OP3_sig  ;
wire OP4_sig  ;
wire OP5_sig  ;
wire OUT_sig  ;
wire IDLE_sig ;


//design


assign LOAD_sig = cmd_valid ? (cmd==3'b001 ? 1 : 0) : 0 ;
assign OP0_sig = cmd_valid ? (cmd==3'b000 ? 1 : 0) : 0 ;
assign OP2_sig = cmd_valid ? (cmd==3'b010 ? 1 : 0) : 0 ;
assign OP3_sig = cmd_valid ? (cmd==3'b011 ? 1 : 0) : 0 ;
assign OP4_sig = cmd_valid ? (cmd==3'b100 ? 1 : 0) : 0 ;
assign OP5_sig = cmd_valid ? (cmd==3'b101 ? 1 : 0) : 0 ;

assign OP1_sig = tag_op1 ;

assign OUT_sig = tag_out ;

assign IDLE_sig = tag_idle ;

assign busy = (state_cs==IDLE) ? 0 : 1 ;


always@(posedge clk or posedge reset)     //FSM change
begin
	if(reset)
	begin
		state_cs <= IDLE ;
	end
	else 
	begin
		state_cs <= state_ns ;	
	end
end

always@(*)                              //state_ns change
begin
	case(state_cs)
	IDLE:begin
		 if(LOAD_sig)
			state_ns = LOAD ;
		 else if(OP0_sig||OP2_sig||OP3_sig||OP4_sig||OP5_sig)
			state_ns = OP   ;
		 else 
			state_ns = state_ns ;
		 end
		 
	LOAD:begin
		 if(OP1_sig)
			state_ns = OP ;
		 else
			state_ns = state_ns ;
		 end
		 
	 OP :begin
		 if(OUT_sig)
			state_ns = OUT ;
		 else
			state_ns = state_ns ;
		 end
	OUT :begin
		 if(IDLE_sig)
			state_ns = IDLE ;
		 else
		    state_ns = state_ns ;
	     end
	endcase
end





always@(posedge clk)                    // load data
begin
	if(state_cs==LOAD)
	begin
		if(counter<6'd36)
		begin
		tag_idle <= 0 ;
		in_buffer[counter] <= datain ;
		counter <= counter + 1 ; 
		//tag_op1 <= 0 ;
		end
		else if (counter>=6'd36)
		begin
		tag_op1 <= 1 ;
		
		end
	end
	else
	begin
		counter <= 6'd0;
		tag_op1 <= 0 ;
	end
end

always@(state_cs)                    // operation
begin
	if (state_cs==OP)
	begin
		   if(OP0_sig)
		   begin
			out_buffer[0] = in_buffer[record];out_buffer[1] = in_buffer[record+1]; out_buffer[2] = in_buffer[record+2] ; 
			out_buffer[3] = in_buffer[record+6];out_buffer[4] = in_buffer[record+7]; out_buffer[5] = in_buffer[record+8] ; 
			out_buffer[6] = in_buffer[record+12];out_buffer[7] = in_buffer[record+13]; out_buffer[8] = in_buffer[record+14] ;
			record = record ;
			tag_out = 1 ;
		   end
		   
		   else if(OP1_sig)
		   begin
			out_buffer[0] = in_buffer[14];out_buffer[1] = in_buffer[15]; out_buffer[2] = in_buffer[16] ; 
			out_buffer[3] = in_buffer[20];out_buffer[4] = in_buffer[21]; out_buffer[5] = in_buffer[22] ; 
			out_buffer[6] = in_buffer[26];out_buffer[7] = in_buffer[27]; out_buffer[8] = in_buffer[28] ;
			record = 6'd14 ;
			tag_out = 1 ;
		   end
		   
		   else if(OP2_sig)
		    begin
			if(record==32'd0||record==32'd1||record==32'd2||record==32'd6||record==32'd7||record==32'd8||record==32'd12||record==32'd13||record==32'd14||
			   record==32'd18||record==32'd19||record==32'd20)
			begin
			out_buffer[0] = in_buffer[record+1];out_buffer[1] = in_buffer[record+2]; out_buffer[2] = in_buffer[record+3] ; 
			out_buffer[3] = in_buffer[record+7];out_buffer[4] = in_buffer[record+8]; out_buffer[5] = in_buffer[record+9] ; 
			out_buffer[6] = in_buffer[record+13];out_buffer[7] = in_buffer[record+14]; out_buffer[8] = in_buffer[record+15] ;
			record = record+1;
			tag_out = 1 ;
			end
			else 
			begin
			out_buffer[0] = in_buffer[record];out_buffer[1] = in_buffer[record+1]; out_buffer[2] = in_buffer[record+2] ; 
			out_buffer[3] = in_buffer[record+6];out_buffer[4] = in_buffer[record+7]; out_buffer[5] = in_buffer[record+8] ; 
			out_buffer[6] = in_buffer[record+12];out_buffer[7] = in_buffer[record+13]; out_buffer[8] = in_buffer[record+14] ;
			record = record ;
			tag_out = 1 ;
		   	end
		    end
		   
		   else if(OP3_sig)
		   begin
			if(record==32'd1||record==32'd2||record==32'd3||record==32'd7||record==32'd8||record==32'd9||record==32'd13||record==32'd14||record==32'd15||
			   record==32'd19||record==32'd20||record==32'd21)
			begin
			out_buffer[0] = in_buffer[record-1];out_buffer[1] = in_buffer[record]; out_buffer[2] = in_buffer[record+1] ; 
			out_buffer[3] = in_buffer[record+5];out_buffer[4] = in_buffer[record+6]; out_buffer[5] = in_buffer[record+7] ; 
			out_buffer[6] = in_buffer[record+11];out_buffer[7] = in_buffer[record+12]; out_buffer[8] = in_buffer[record+13] ;
			record = record-1;
			tag_out = 1 ;
			end
			else 
			begin
			out_buffer[0] = in_buffer[record];out_buffer[1] = in_buffer[record+1]; out_buffer[2] = in_buffer[record+2] ; 
			out_buffer[3] = in_buffer[record+6];out_buffer[4] = in_buffer[record+7]; out_buffer[5] = in_buffer[record+8] ; 
			out_buffer[6] = in_buffer[record+12];out_buffer[7] = in_buffer[record+13]; out_buffer[8] = in_buffer[record+14] ;
			record = record ;
			tag_out = 1 ;
		  	end
   		   end
		
		   else if(OP4_sig)
		   begin
			if(record==32'd6||record==32'd7||record==32'd8||record==32'd9||record==32'd12||record==32'd13||record==32'd14||record==32'd15||record==32'd18||
			   record==32'd19||record==32'd20||record==32'd21)
			begin
			out_buffer[0] = in_buffer[record-6];out_buffer[1] = in_buffer[record-5]; out_buffer[2] = in_buffer[record-4] ; 
			out_buffer[3] = in_buffer[record];out_buffer[4] = in_buffer[record+1]; out_buffer[5] = in_buffer[record+2] ; 
			out_buffer[6] = in_buffer[record+6];out_buffer[7] = in_buffer[record+7]; out_buffer[8] = in_buffer[record+8] ;
			record = record-6;
			tag_out = 1 ;
			end
			else 
			begin
			out_buffer[0] = in_buffer[record];out_buffer[1] = in_buffer[record+1]; out_buffer[2] = in_buffer[record+2] ; 
			out_buffer[3] = in_buffer[record+6];out_buffer[4] = in_buffer[record+7]; out_buffer[5] = in_buffer[record+8] ; 
			out_buffer[6] = in_buffer[record+12];out_buffer[7] = in_buffer[record+13]; out_buffer[8] = in_buffer[record+14] ;
			record = record ;
			tag_out = 1 ;
		  	end
   		   end
		   
		   else if(OP5_sig)
		   begin
			if(record==32'd6||record==32'd7||record==32'd8||record==32'd9||record==32'd12||record==32'd13||record==32'd14||record==32'd15||record==32'd0||
			   record==32'd1||record==32'd2||record==32'd3)
			begin
			out_buffer[0] = in_buffer[record+6];out_buffer[1] = in_buffer[record+7]; out_buffer[2] = in_buffer[record+8] ; 
			out_buffer[3] = in_buffer[record+12];out_buffer[4] = in_buffer[record+13]; out_buffer[5] = in_buffer[record+14] ; 
			out_buffer[6] = in_buffer[record+18];out_buffer[7] = in_buffer[record+19]; out_buffer[8] = in_buffer[record+20] ;
			record = record+6;
			tag_out = 1 ;
			end
			else 
			begin
			out_buffer[0] = in_buffer[record];out_buffer[1] = in_buffer[record+1]; out_buffer[2] = in_buffer[record+2] ; 
			out_buffer[3] = in_buffer[record+6];out_buffer[4] = in_buffer[record+7]; out_buffer[5] = in_buffer[record+8] ; 
			out_buffer[6] = in_buffer[record+12];out_buffer[7] = in_buffer[record+13]; out_buffer[8] = in_buffer[record+14] ;
			record = record ;
			tag_out = 1 ;
		   	end
			end
	end		
	else
		tag_out = 0 ;
end


always@(posedge clk or posedge reset)       //output
begin
	if(reset)
	begin
		dataout <= 8'b00000000 ;
		output_valid <= 0 ;
	end
	else if(state_cs==OUT)
	    begin
		 if(count < 4'b1001)
		 begin
		 count <= count + 1 ;
		 dataout <= out_buffer[count];
		 output_valid <= 1 ;
		 //tag_idle <= 0 ;
		 end
		 else
		 begin
		 output_valid <= 0 ;
		 tag_idle <= 1 ;
		 end
		end
	else 
	begin
		count <= 4'b0000 ;
		tag_idle <= 0 ;
	end	
end






                                                                                     
endmodule
