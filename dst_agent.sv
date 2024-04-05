class dst_agent_config extends uvm_object;
	
	`uvm_object_utils(dst_agent_config)

	uvm_active_passive_enum is_active=UVM_ACTIVE;

	virtual slave_if vif;

        function new(string name="");
                super.new(name);
        endfunction

endclass





class dst_xtn extends uvm_sequence_item;

	`uvm_object_utils_begin(dst_xtn)
		`uvm_field_int(pwdata,UVM_ALL_ON)
		`uvm_field_int(penable,UVM_ALL_ON)
		`uvm_field_int(paddr,UVM_ALL_ON)
		`uvm_field_int(pselx,UVM_ALL_ON)
		`uvm_field_int(pwrite,UVM_ALL_ON)
	`uvm_object_utils_end



        logic  [31:0] pwdata;
	logic [3:0] pselx;
	
	logic [31:0] paddr;
	
	logic penable;
	
	logic pwrite;

	logic [31:0] prdata;
	
	
        function new(string name="");
                super.new(name);
        endfunction

endclass


class dst_driver extends uvm_driver#(dst_xtn);
	
	`uvm_component_utils(dst_driver)

	dst_agent_config m_cfg;
	
	virtual	slave_if.S_DRV_MP vif;
		
        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(dst_agent_config)::get(this,"","dst_agent_config",m_cfg))
			`uvm_fatal(get_type_name(),"error from dst driver")
	endfunction

	function void connect_phase(uvm_phase phase);

		vif=m_cfg.vif;
	endfunction

	task send_to_dut();
      while(vif.s_drv_cb.pselx==0)
        	@(vif.s_drv_cb);
      
      if(vif.s_drv_cb.pwrite==0)
				vif.s_drv_cb.prdata<=$random;
		
		repeat(2)
			@(vif.s_drv_cb);
	endtask
	
	task run_phase(uvm_phase phase);
		//`uvm_info(get_type_name(),"from dest driver",UVM_LOW)	
		forever 
			send_to_dut();
	endtask			
	

endclass


class dst_monitor extends uvm_monitor;
	
	`uvm_component_utils(dst_monitor)

	dst_agent_config m_cfg;
	
	virtual slave_if.S_MON_MP vif;
		
	uvm_analysis_port#(dst_xtn) ap;

	dst_xtn a;
		
        function new(string name="",uvm_component parent);

                super.new(name,parent);

		ap=new("ap",this);

        endfunction

	 function void build_phase(uvm_phase phase);
                if(!uvm_config_db#(dst_agent_config)::get(this,"","dst_agent_config",m_cfg))
                        `uvm_fatal(get_type_name(),"error from dst monitor")
        endfunction

        function void connect_phase(uvm_phase phase);

                vif=m_cfg.vif;
        endfunction

	task collect_data();
		a=dst_xtn::type_id::create("a");
			
      while(!vif.s_mon_cb.penable==1)
        @(vif.s_mon_cb);
			a.paddr=vif.s_mon_cb.paddr;            
	                a.pwrite=vif.s_mon_cb.pwrite;
                        a.pselx=vif.s_mon_cb.pselx;
        	
		if(a.pwrite==1)
			a.pwdata=vif.s_mon_cb.pwdata;
		else
			a.prdata=vif.s_mon_cb.prdata;
      
      @(vif.s_mon_cb);
      @(vif.s_mon_cb);
      
      ap.write(a);
		
		//`uvm_info(get_type_name(),a.sprint(),UVM_LOW)       	
		     
	endtask

			
		
	
	task run_phase(uvm_phase phase);
		forever 
			collect_data();
	endtask		
endclass


class dst_agent extends uvm_agent;

	dst_driver drv_h;
	dst_monitor mon_h;

	dst_agent_config m_cfg;

	`uvm_component_utils(dst_agent)

        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction
	
	function void build_phase(uvm_phase phase);
	
		if(!uvm_config_db#(dst_agent_config)::get(this,"","dst_agent_config",m_cfg))
			`uvm_fatal(get_type_name(),"this is errop from dst agent")

		if(m_cfg.is_active==UVM_ACTIVE)
			drv_h=dst_driver::type_id::create("drv_h",this);

		mon_h=dst_monitor::type_id::create("mon_h",this);
	endfunction

	

endclass


class dst_agent_top extends uvm_agent;

	`uvm_component_utils(dst_agent_top)

	dst_agent agnt_h;

        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction

	function void build_phase(uvm_phase phase);
		agnt_h=dst_agent::type_id::create("agnt_h",this);
	endfunction


endclass

