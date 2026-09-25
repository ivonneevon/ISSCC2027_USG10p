module F_CTRL_DIODE
(
	input 					clk,
	input 					rst_n,
	input 					trig,

	input					ext_h,
	input					scan_en,
	input					scan_in,
	output 					scan_out,
	output	reg 				p_clk,

	output					F_0V_EN,
	output					F_10V_EN,
	output					F_20V_EN,
	output					F_30V_EN,
	output 					F_PASS_EN,
	output					F_OUTPUT_IDLE_EN,
	output					F_OUTPUT_HOLD_EN
	);

	parameter char_t_width 		= 8;
	parameter rec_t_width 		= 6;   						
	parameter num_model 		= 14;
	parameter num_time_model 	= 8;	
	parameter nonoverlap_t_width = 3;
	parameter time_bit_width	= 17;

	reg [3 : 0] 							fsm;
	localparam 							IDLE = 0;
	localparam 							C1	 = 1;
	localparam 							R1	 = 2;
	localparam 							C2   = 3;
	localparam 							R2   = 4;
	localparam 							C3   = 5;
	localparam 							R3   = 6;
	localparam 							HOLD = 7;
	localparam 							N1 = 8;
	localparam 							N2 = 9;
	localparam 							N3 = 10;

	reg	[8:0]	sw_ctrl;


	wire [char_t_width-1 : 0]							charge_time [num_time_model-1 : 0];
	wire [rec_t_width-1 : 0] 							recover_time [num_time_model-1 : 0];
	reg [char_t_width-1 : 0] 							cnt;
	reg 												fb;
	wire [char_t_width-1 : 0]							charge_time_ed;
	wire [rec_t_width-1 : 0]							recover_time_ed;


	reg [time_bit_width-1:0] 				time_para;
	reg 									trig_in;
	wire [nonoverlap_t_width-1 : 0]		pre_pass_time_ed;

	reg									nov;
	reg [nonoverlap_t_width-1 : 0]		nov_cnt;
	wire [nonoverlap_t_width-1 : 0]		nonoverlap_ed;
	assign nonoverlap_ed = (ext_h) ? time_para[time_bit_width-1 : time_bit_width-3] : 3'd5;

	assign F_0V_EN	 			= 	sw_ctrl[6];
	assign F_10V_EN	 			= 	sw_ctrl[5];
	assign F_20V_EN 				=	sw_ctrl[4];
	assign F_30V_EN				= 	sw_ctrl[3];
	assign F_PASS_EN				=	sw_ctrl[2];
	assign F_OUTPUT_IDLE_EN		= 	sw_ctrl[1];
	assign F_OUTPUT_HOLD_EN 		= 	sw_ctrl[0];

	assign charge_time_ed = (ext_h)? time_para[13 : 6] : 8'd120;
	assign recover_time_ed = (ext_h)? time_para[5 : 0] : 6'd18;
	assign pre_pass_time_ed = 2'd2;

	// fsm
	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			fsm <= IDLE;
			cnt <= 8'd0;
			fb <= 0;
			trig_in <= trig;
			nov <= 1'b0;
			nov_cnt <= 0;
		end
		else begin
			trig_in <= trig;
			case(fsm)
				IDLE : begin
					if (trig_in) begin
						fsm <= C1;
						cnt <= 'd0;
						fb <= 'd0;
						nov <= (nonoverlap_ed != 3'd0);
						nov_cnt <= 0;
					end
				end
				C1 : begin
					if (nov) begin
						if (nov_cnt >= nonoverlap_ed - 1'b1) begin
							nov <= 1'b0;
							nov_cnt <= 0;
						end
						else nov_cnt <= nov_cnt + 1'b1;
					end
					else if (cnt == charge_time_ed) begin
						cnt <= 'd0;
						fsm <= R1;
					end
					else begin
						cnt<= cnt + 1;
					end
				end
				R1 : begin
					if (cnt == recover_time_ed) begin
						cnt <= 'd0;
						fsm <= C2;
						nov <= (nonoverlap_ed != 3'd0);
						nov_cnt <= 0;
					end
					else begin
						cnt <= cnt + 1;
					end
				end
				C2 : begin
					if (nov) begin
						if (nov_cnt >= nonoverlap_ed - 1'b1) begin
							nov <= 1'b0;
							nov_cnt <= 0;
						end
						else nov_cnt <= nov_cnt + 1'b1;
					end
					else if (cnt == charge_time_ed) begin
						cnt <= 'd0;
						fsm <= R2;
					end
					else begin
						cnt<= cnt + 1;
					end
				end
				R2 : begin
					if (cnt == recover_time_ed) begin
						cnt <= 'd0;
						fsm <= C3;
						nov <= (nonoverlap_ed != 3'd0);
						nov_cnt <= 0;
					end
					else begin
						cnt <= cnt + 1;
					end
				end
				C3 : begin
					if (nov) begin
						if (nov_cnt >= nonoverlap_ed - 1'b1) begin
							nov <= 1'b0;
							nov_cnt <= 0;
						end
						else nov_cnt <= nov_cnt + 1'b1;
					end
					else if (cnt == charge_time_ed) begin
						cnt <= 'd0;
						fsm <= R3;
					end
					else begin
						cnt<= cnt + 1;
					end
				end
				R3 : begin
					if (cnt == recover_time_ed) begin
						cnt <= 'd0;
						if (fb) begin
							fb <= 'd0;
							fsm <= IDLE;
						end
						else begin
							fb <= 'd1;
							fsm <= HOLD;
						end
					end
					else begin
						cnt <= cnt + 1;
					end
				end
				HOLD : begin
					cnt <= 0;
					if (~trig_in) begin
						fsm <= C1;
						nov <= (nonoverlap_ed != 3'd0);
						nov_cnt <= 0;
					end
				end

				default : fsm <= IDLE;
			endcase
		end
	end

	//output sw_ctrl
	always @ (*) begin
		if (nov) sw_ctrl <= 7'b0000_0_00;
		else begin
			case (fsm)
				IDLE : sw_ctrl <= 7'b1000_0_10;
				C1   : sw_ctrl <= (~fb) ? 7'b0100_1_00 : 7'b0010_1_00;
				R1	 : sw_ctrl <= 7'b0000_0_00;
				C2   : sw_ctrl <= (~fb) ? 7'b0010_1_00 : 7'b0100_1_00;
				R2   : sw_ctrl <= 7'b0000_0_00;
				C3   : sw_ctrl <= (~fb) ? 7'b0001_1_00 : 7'b1000_1_00;
				R3   : sw_ctrl <= 7'b0000_0_00;
				HOLD : sw_ctrl <= 9'b0001_1_01;
				default : sw_ctrl <= 7'b0000_0_00;
			endcase
		end
	end


	// parameter upload
	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			time_para <= {
							3'd5, 8'd120, 6'd16
						 };
		end
		else begin
			if (scan_en) begin
				time_para <= {time_para[time_bit_width-2:0] , scan_in};
			end
		end
	end
	assign scan_out = time_para[time_bit_width - 1];

	reg 		[7:0] p_cnt;
	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			p_clk <= 0;
			p_cnt <= 8'b0;
		end
		else begin
			if (p_cnt == 99) begin
				p_cnt <= 8'b0;
				p_clk <= ~p_clk;
			end
			else begin
				p_cnt <= p_cnt + 1;
			end
		end
	end

endmodule
