class test extends uvm_test;
	
	`uvm_component_utils(test)

	env env_h;

	int x=1;

	env_config m_cfg;

	src_agent_config src_m_cfg[];

	dst_agent_config dst_m_cfg[];

	//single_sequence seq_h;
	
  	burst_sequence seq_h;

	function new(string name="",uvm_component parent);
		
		super.new(name,parent);

	endfunction

	function void build_phase(uvm_phase phase);
	
		super.build_phase(phase);

		m_cfg=env_config::type_id::create("m_cfg");
	
		if(!uvm_config_db#(virtual master_if)::get(this,"","vif1",m_cfg.vif1))
			`uvm_fatal(get_type_name(),"error from test getting vif")

		if(!uvm_config_db#(virtual slave_if)::get(this,"","vif2",m_cfg.vif2))
                        `uvm_fatal(get_type_name(),"error from test getting vif")

	
			
		m_cfg.no_of_agents=x;
		
		m_cfg.has_scoreboard=1;

		m_cfg.has_src_agent=1;

		m_cfg.has_dst_agent=1;
	
		dst_m_cfg=new[x];
	
		foreach(dst_m_cfg[i])
			begin
				dst_m_cfg[i]=dst_agent_config::type_id::create($sformatf("dst_m_cfg[%0d]",i));
				dst_m_cfg[i].is_active=UVM_ACTIVE;
				dst_m_cfg[i].vif=m_cfg.vif2;
			end
		
		src_m_cfg=new[x];
		foreach(src_m_cfg[i])
                        begin
                                src_m_cfg[i]=src_agent_config::type_id::create($sformatf("src_m_cfg[%0d]",i));
                                src_m_cfg[i].is_active=UVM_ACTIVE;
				src_m_cfg[i].vif=m_cfg.vif1;
                        end

		m_cfg.dst_m_cfg=dst_m_cfg;

		m_cfg.src_m_cfg=src_m_cfg;

		uvm_config_db#(env_config)::set(this,"*","env_config",m_cfg);	

		env_h=env::type_id::create("env_h",this);


	
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		
		uvm_top.print_topology();
	endfunction	

	task run_phase(uvm_phase phase);

		phase.raise_objection(this);
      
      repeat(3)
        	begin
	
      seq_h=burst_sequence::type_id::create("burst_sequence");
	
		seq_h.start(env_h.src_agnt_h[0].agnt_h.seqr_h);
            
            end  
      
      	#150;
		
		phase.drop_objection(this);

	endtask

endclass


class extended_test extends test;
  
  `uvm_component_utils(extended_test)
  
  single_sequence seqq_h;
  	
  function new(string name="",uvm_component parent);
    
    super.new(name,parent);
  
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
  endfunction
  
  task run_phase(uvm_phase phase);

		phase.raise_objection(this);
	
		seqq_h=single_sequence::type_id::create("single_sequence");
	
		seqq_h.start(env_h.src_agnt_h[0].agnt_h.seqr_h);
      
      	#150;
		
		phase.drop_objection(this);

	endtask
  
endclass 
  
  
    
  

