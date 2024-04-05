class src_agent_config extends uvm_object;
	
	`uvm_object_utils(src_agent_config)

	uvm_active_passive_enum is_active=UVM_ACTIVE;

	virtual master_if vif;




        function new(string name="");
                super.new(name);
        endfunction

endclass


class src_xtn extends uvm_sequence_item;
	
	`uvm_object_utils(src_xtn)

	rand bit hwrite;

	rand bit [31:0] hwdata;

	rand bit [31:0] haddr;
  
  static bit [31:0] addr;
	
	rand bit [2:0] hsize;

	rand bit [2:0] hburst;

	rand bit [1:0] htrans;

	 bit [31:0] hrdata;

	bit hreadyin;

	bit hreadyout;
	
	bit [1:0] hresp;

	bit hresetn;

	rand bit [9:0] length;

  constraint  one{soft haddr inside {[32'h80000000:32'h800003ff],[32'h84000000:32'h840003ff],[32'h88000000:32'h880003ff],[32'h8c000000:32'h8c0003ff]};}

	constraint two{(hsize==1)->(haddr%2==0);
		       (hsize==2)->(haddr%4==0);

			//hwdata inside {[5:99]};
		    	}

	constraint three{
			((2**hsize)*length)<1024;
	} 

	constraint four{
			solve hsize before length;
			solve hsize before haddr;
	}

	constraint five{
			hsize==0;
      		hwrite==1;
	}

  
  function void post_randomize();
    
    addr=haddr;
    `uvm_info(get_type_name(),$sformatf("UVM sequence addr is %0h",addr),UVM_LOW)
  endfunction
    	
	
	

	function new(string name="");
		super.new(name);
	endfunction

	virtual function void do_print(uvm_printer printer);
		printer.print_field("haddr",haddr,32,UVM_HEX);
		printer.print_field("hwrite",hwrite,1,UVM_DEC);
      printer.print_field("hwdata",hwdata,32,UVM_HEX);
      printer.print_field("hrdata",hrdata,32,UVM_HEX);
		printer.print_field("hburst",hburst,3,UVM_DEC);
		printer.print_field("htrans",htrans,2,UVM_DEC);
		printer.print_field("hsize",hsize,3,UVM_DEC);

	endfunction
		



endclass


class src_sequence extends uvm_sequence#(src_xtn);

	`uvm_object_utils(src_sequence)

	bit [2:0] hburst;
	bit [31:0] haddr;
	bit [2:0] hsize;
	bit hwrite;
	bit [9:0] length;
	

        function new(string name="");
                super.new(name);
        endfunction

endclass


class single_sequence extends src_sequence;
	
	`uvm_object_utils(single_sequence)
  
  	src_xtn aa;
	
	
	
	function new(string name="");
		super.new(name);
	endfunction

  task body();
      
		repeat(10)
		begin
		req=src_xtn::type_id::create("req");
		start_item(req);
          assert(req.randomize() with {hburst==3'b000;htrans==2'b10;hwrite==1'b1;});
		finish_item(req);
		end
	endtask

endclass

class burst_sequence extends src_sequence;

	`uvm_object_utils(burst_sequence)

		
	function new(string name="");
		super.new(name);
	endfunction

	task body();
		
      `uvm_do_with(req,{hburst ==7;htrans==2'b10;})
		
		haddr=req.haddr;
		hburst=req.hburst;
		hwrite=req.hwrite;
		hsize=req.hsize;
		length=req.length;
      
	
		if(hburst==3'b001)
          	begin
			repeat(length-1)
				begin
					if(hsize==2'b00)
						`uvm_do_with(req,{hburst==3'b001;htrans==2'b11;haddr==addr+1;})
					else if(hsize==2'b01)
						`uvm_do_with(req,{hburst==3'b001;htrans==2'b11;haddr==addr+2;})
					else 
						`uvm_do_with(req,{hburst==3'b001;htrans==2'b11;haddr==addr+4;})
                          
				end
                      `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})
                      end         
        
                      
		//incr 4 logic ....3'b011
		else if(hburst==3'b011)
          
          begin
			repeat(3)
				begin
					if(hsize==2'b00)
                                                `uvm_do_with(req,{hburst==3'b011;htrans==2'b11;haddr==addr+1;})
                                        else if(hsize==2'b01)
                                                `uvm_do_with(req,{hburst==3'b011;htrans==2'b11;haddr==addr+2;})
                                        else
                                                `uvm_do_with(req,{hburst==3'b011;htrans==2'b11;haddr==addr+4;})
				end
                                          
                                          `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})
  
                                          
                                          end   
		//incr 8 logic ....3'b101
		else if(hburst==3'b101)
          
         begin
                        repeat(7)
                                begin
                                        if(hsize==2'b00)
                                                `uvm_do_with(req,{hburst==3'b101;htrans==2'b11;haddr==addr+1;})
                                        else if(hsize==2'b01)
                                                `uvm_do_with(req,{hburst==3'b101;htrans==2'b11;haddr==addr+2;})
                                        else
                                                `uvm_do_with(req,{hburst==3'b101;htrans==2'b11;haddr==addr+4;})
                                end
                                          
                                          
                                        `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})

                                          
                                          end                                 
		//incr 16 logic ....3'b111
                else if(hburst==3'b111)
                  
                  begin
                        repeat(15)
                                begin
                                        if(hsize==2'b00)
                                                `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr==addr+1;})
                                        else if(hsize==2'b01)
                                                `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr==addr+2;})
                                        else
                                                `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr==addr+4;})
                                end
                                          
                                         `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})
 
                                          
                                          end
		//wrap 4 logic ...3'b010
		else if(hburst==3'b010)
          
          begin
                        repeat(3)
                                begin
                                        if(hsize==2'b00)
                                              `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr[31:2]==haddr[31:2];haddr[1:0]==2'(addr[1:0]+1);})
                                        else if(hsize==2'b01)
                                              `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr[31:3]==haddr[31:3];haddr[2:0]==3'(addr[2:0]+2);})
                                        else
                                              `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr[31:4]==haddr[31:4];haddr[3:0]==4'(addr[3:0]+4);})
                                end
                                          
                                        `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})

                                          
                                          end
                                          
	
		 //wrap 8 logic ...3'b100
                else if(hburst==3'b100)
                  begin
                        repeat(7)
                                begin
                                        if(hsize==2'b00)
                                             `uvm_do_with(req,{hburst==3'b100;htrans==2'b11;haddr[31:3]==haddr[31:3];haddr[2:0]==3'(addr[2:0]+1);})
                                        else if(hsize==2'b01)
                                             `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr[31:4]==haddr[31:4];haddr[3:0]==4'(addr[3:0]+2);})
                                        else
                                             `uvm_do_with(req,{hburst==3'b111;htrans==2'b11;haddr[31:5]==haddr[31:5];haddr[4:0]==5'(addr[4:0]+4);})
                                end
                                          
                                         `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})

                                          
                                          end      
		//wrap 16 logic --3'b110
		else if(hburst==3'b110)
          begin
                                
                        repeat(15)
                                begin
                                  	
                                        if(hsize==2'b00)
                                                `uvm_do_with(req,{hburst==3'b110;htrans==2'b11;haddr[31:4]==addr[31:4];haddr[3:0]==4'(addr[3:0]+1);})
                                        else if(hsize==2'b01)
                                             `uvm_do_with(req,{hburst==3'b110;htrans==2'b11;haddr[31:5]==addr[31:5];haddr[4:0]==5'(addr[4:0]+2);})
                                        else
                                             `uvm_do_with(req,{hburst==3'b110;htrans==2'b11;haddr[31:6]==addr[31:6];haddr[5:0]==6'(addr[5:0]+4);})
                                end
                                          `uvm_do_with(req,{hburst==3'b000;htrans==2'b00;haddr==0;})
  
                                          
                                          end    
	
	endtask

endclass




		



class src_sequencer extends uvm_sequencer#(src_xtn);

	`uvm_component_utils(src_sequencer)

        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction

endclass

                       
                                  
class src_driver extends uvm_driver#(src_xtn);

	`uvm_component_utils(src_driver)

	virtual master_if.M_DRV_MP vif;

	src_agent_config m_cfg;

	function new(string name="",uvm_component parent);

		super.new(name,parent);
	
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(src_agent_config)::get(this,"","src_agent_config",m_cfg))
			`uvm_fatal(get_type_name(),"from driver msater error")
		
	endfunction		

	function void connect_phase(uvm_phase phase);
		vif=m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		      		vif.m_drv_cb.hreadyin<=1'b1;

		@(vif.m_drv_cb);
			vif.m_drv_cb.hresetn<=1'b0;
		@(vif.m_drv_cb)
			vif.m_drv_cb.hresetn<=1'b1;

		forever begin
			seq_item_port.get_next_item(req);
			//`uvm_info(get_type_name(),req.sprint(),UVM_LOW)
			send_to_dut();
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut();
      

		
				       vif.m_drv_cb.hwrite<=req.hwrite;
	
		                vif.m_drv_cb.haddr<=req.haddr;

		                vif.m_drv_cb.hsize<=req.hsize;

		                vif.m_drv_cb.htrans<=req.htrans;

				

				@(vif.m_drv_cb);
      		
      while(!vif.m_drv_cb.hreadyout==1)
        @(vif.m_drv_cb);
			
				if(req.hwrite)
					vif.m_drv_cb.hwdata<=req.hwdata;

	endtask			




endclass

class src_monitor extends uvm_monitor;
	
	`uvm_component_utils(src_monitor)
	
	virtual master_if.M_MON_MP vif;
  
  			src_xtn a;


	src_agent_config m_cfg;
			
	uvm_analysis_port#(src_xtn) ap;

        function new(string name="",uvm_component parent);

                super.new(name,parent);
		ap=new("ap",this);
        endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(src_agent_config)::get(this,"","src_agent_config",m_cfg))
			`uvm_fatal(get_type_name(),"error from source monitor")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=m_cfg.vif;
	endfunction

	task collect_data();
		a=src_xtn::type_id::create("a");

      while(!(vif.m_mon_cb.hreadyout &&(vif.m_mon_cb.htrans==2'b10||vif.m_mon_cb.htrans==2'b11)))
        	@(vif.m_mon_cb);
				
			a.htrans=vif.m_mon_cb.htrans;

			                        a.hwrite=vif.m_mon_cb.hwrite;

		                        a.hsize=vif.m_mon_cb.hsize;

		                        a.haddr=vif.m_mon_cb.haddr;

		                        a.hburst=vif.m_mon_cb.hburst;
      		
      
      
			@(vif.m_mon_cb);
		
      while(!(vif.m_mon_cb.hreadyout &&(vif.m_mon_cb.htrans==2'b10||vif.m_mon_cb.htrans==2'b11)))
			@(vif.m_mon_cb);
      
      	if(a.hwrite)
			a.hwdata=vif.m_mon_cb.hwdata;
			else 
			a.hrdata=vif.m_mon_cb.hrdata;
			
      ap.write(a);
		
		//`uvm_info(get_type_name(),"from src monitor data",UVM_LOW)
		//a.print();
		
	
	endtask

	task run_phase(uvm_phase phase);
      repeat(3) @(vif.m_mon_cb);
		forever begin
			collect_data();
		end
	endtask

	

endclass

                                
                                  
class src_agent extends uvm_agent;

	`uvm_component_utils(src_agent)
	
	src_agent_config m_cfg;
	
	src_driver drv_h;
	
	src_monitor mon_h;

	src_sequencer seqr_h;
	

        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction

	function void build_phase(uvm_phase phase);

		if(!uvm_config_db#(src_agent_config)::get(this,"","src_agent_config",m_cfg))
			`uvm_fatal(get_type_name(),"error from src agent")
		
		if(m_cfg.is_active==UVM_ACTIVE)
			begin		
				seqr_h=src_sequencer::type_id::create("seqr_h",this);
				drv_h=src_driver::type_id::create("drv_h",this);
			end

		mon_h=src_monitor::type_id::create("mon_h",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		
		if(m_cfg.is_active==UVM_ACTIVE)
			drv_h.seq_item_port.connect(seqr_h.seq_item_export);
	
	endfunction
		
endclass

                                  
class src_agent_top extends uvm_agent;
		
	`uvm_component_utils(src_agent_top)

	src_agent agnt_h;

        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction


	function void build_phase(uvm_phase phase);
		
		agnt_h=src_agent::type_id::create("agnt_h",this);

	endfunction

endclass

                                  
                                  
