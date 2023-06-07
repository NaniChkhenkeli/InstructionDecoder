module dec(instruction, af, i, ALU_MUX_SEL, cad, GP_WE, GP_MUX_SEL, bf, DM_WE, Shift_type, PC_MUX_SEL);
	input [31:0] instruction;
	output reg [3:0] af;
	output reg i, ALU_MUX_SEL;
	output reg [4:0] cad;
	output reg GP_WE;
	output reg [1:0] GP_MUX_SEL;
	output reg [3:0] bf;
	output reg DM_WE;
	output reg [2:0] Shift_type;
	output reg [1:0] PC_MUX_SEL;
	
	// Instruction parts
	reg rtype, itype, jtype;
	reg [5:0] opc, fun;
	reg [4:0] rs, rt, rd, sa;
	reg [15:0] imm;
	reg [25:0] iindex;
	
	// Decoder logic
	always @ (*) begin
		
		// Types and opcode
		opc = instruction[31:26];
		rtype = (opc == 6'b000000 || opc == 6'b010000);
		jtype = (opc == 6'b000010 || opc == 6'b000011);
		itype = !(rtype || jtype);
		
		// Registers
		rs = instruction[25:21];
		rt = instruction[20:16];
		rd = instruction[15:11];
		
		// Shift amount
		sa = instruction[10:6];
		
		// Rtype instruction
		fun = instruction[5:0];
		
		// Itype immediate
		imm = instruction[15:0];
		// Jtype iindex
		iindex = instruction[25:0];
		// ALU
		af[2:0] = rtype ? fun[2:0] : opc[2:0];
		af[3] = rtype ? fun[3] : opc[2] & opc[1];
		i = itype && (opc[5:3] == 3'b001);
		ALU_MUX_SEL = rtype && (opc[5:4] == 2'b10);
		// Shifter
		Shift_type = fun[1:0];
		// BCE
		bf[3:1] = opc[2:0];
		bf[0] = rt[0];
		// MEMORY
		DM_WE = opc == 6'b101011;
		// GPR
		if (opc == 6'b000011) cad = 5'b11111;
		else if (rtype) cad = rd;
		else cad = rt;
		GP_WE = (opc[5:3] == 3'b100 || i || ALU_MUX_SEL || (opc == 6'b000011) ||
					(rtype && (fun == 6'b001001 || fun == 6'b000010 ||  fun == 6'b000011 ||  fun == 0))
				  );
		
		if (i || ALU_MUX_SEL) GP_MUX_SEL = 2'b00;
		else if (opc == 6'b100011) GP_MUX_SEL = 2'b01;
		else if (rtype && (fun == 6'b000010 ||  fun == 6'b000011 ||  fun == 0)) GP_MUX_SEL = 2'b10;
		else GP_MUX_SEL = 2'b11;
		
		// PC
		if (rtype && fun[5:2] == 4'b0010) PC_MUX_SEL = 2'b00;
		else if (itype && opc[5:3] == 0) PC_MUX_SEL = 2'b01;
		else if (jtype) PC_MUX_SEL = 2'b10;
		else PC_MUX_SEL = 2'b11;
		
	end
	endmodule
	