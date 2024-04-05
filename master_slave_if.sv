interface master_if(input bit clk);

	bit hresetn;

	bit [1:0] htrans;

	bit [31:0] hrdata;
	
	bit hwrite; 

	bit [31:0] haddr;

	bit [31:0] hwdata;

	bit hselAPBif;

	bit [2:0] hburst;

	bit hreadyout;

	bit hreadyin;

	bit [1:0] hresp;

	bit [2:0] hsize;

	clocking m_drv_cb@(posedge clk);

		default input #1 output #1;
	
		output hresetn;
	
		output htrans;

		output hwdata;

		output hburst;
	
		input hreadyout;
	
		output hreadyin;

		output hsize;
	
		output haddr;
		
		output hselAPBif;
	
		output hwrite;

	endclocking
	
	clocking m_mon_cb@(posedge clk);
	
		default input #1 output #1;

		input hreadyout;

		input hrdata;
	
		input hwdata;

		input hresp;
	
		input hwrite;
	
		input htrans;

		input haddr;

		input hsize;
		
		input hburst;

	
	endclocking

	modport M_DRV_MP(clocking m_drv_cb);
	
	modport M_MON_MP(clocking m_mon_cb);

endinterface

	





interface slave_if(input bit clk);
	
	bit penable;
	
	bit pwrite;

	bit [31:0] pwdata;

	bit [31:0] paddr;

	bit [31:0] prdata;

	bit [3:0] pselx;

	clocking s_drv_cb@(posedge clk);
	
		default input #1 output #1;

		input penable;

		input pwrite;
		
		output prdata;
	
		input paddr;

		input pselx;

		input pwdata;		

	endclocking

	clocking s_mon_cb@(posedge clk);
		
		default input #1 output #1;

		input penable;

		input pwrite;
		
		input pwdata;

		input prdata;
	
		input paddr;
	
		input pselx;

	endclocking

	modport S_DRV_MP(clocking s_drv_cb);

	modport S_MON_MP(clocking s_mon_cb);
 
endinterface

