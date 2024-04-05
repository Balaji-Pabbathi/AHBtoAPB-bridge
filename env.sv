class env_config extends uvm_object;

	`uvm_object_utils(env_config)

	src_agent_config src_m_cfg[];

	dst_agent_config dst_m_cfg[];

	virtual master_if vif1;
		
	virtual slave_if vif2;
	
	int no_of_agents=1;

	int has_scoreboard=1;

	int has_src_agent=1;

	int has_dst_agent=1;

        function new(string name="");
                super.new(name);
        endfunction

endclass

class scoreboard extends uvm_scoreboard;

	`uvm_component_utils(scoreboard)
  
  	int size;

	uvm_tlm_analysis_fifo#(src_xtn) fifo1_h;
	
	uvm_tlm_analysis_fifo#(dst_xtn) fifo2_h;
  
  	
  	src_xtn a;
  
  	src_xtn a_cov;
  	
  	dst_xtn b;
  
  	dst_xtn b_cov;
  
  
  src_xtn q1[$];
  
  dst_xtn q2[$];


        function new(string name="",uvm_component parent);

                super.new(name,parent);
		fifo1_h=new("fifo1_h",this);
		fifo2_h=new("fifo2_h",this);	
          
          cg1=new;
          cg2=new;
         
        endfunction
  
  covergroup cg1;
    
   option.per_instance=1;
    
    a: coverpoint a_cov.hburst;
    b: coverpoint a_cov.hsize{
      bins x[]={[0:2]};
    }
    c: coverpoint a_cov.haddr{
      bins aa={[32'h80000000:32'h800003ff]};
      bins bb={[32'h84000000:32'h840003ff]};
      bins cc={[32'h88000000:32'h880003ff]};
      bins dd={[32'h8c000000:32'h8c0003ff]};
    }
    d: coverpoint a_cov.hwdata{
      bins ee={[32'h00000000:32'hffffffff]};
    }
    e: coverpoint a_cov.hrdata{
      bins ee={[32'h00000000:32'hffffffff]};
    }
    f:coverpoint a_cov.htrans{
      bins ff[]={2'b10,2'b11};
    }
    g:coverpoint a_cov.hwrite;
    
    axbxg : cross a,b,g;
  
  endgroup  
  
  
  covergroup cg2;
    
    q1: coverpoint b_cov.penable;
    
    q2: coverpoint b_cov.paddr{
      bins aa={[32'h80000000:32'h800003ff]};
      bins bb={[32'h84000000:32'h840003ff]};
      bins cc={[32'h88000000:32'h880003ff]};
      bins dd={[32'h8c000000:32'h8c0003ff]};
    }
    	
   	q3: coverpoint b_cov.pwdata{
      bins ee={[32'h00000000:32'hffffffff]};
    }
    
    q4:coverpoint b_cov.prdata{
      bins ee={[32'h00000000:32'hffffffff]};
    }
    
    q5: coverpoint b_cov.pwrite;
   
    q6: coverpoint b_cov.pselx{
      bins x1[]={4'b0001,4'b0010,4'b0100,4'b1000};
    }
    
    qcross: cross q1,q6,q5;
  
  endgroup  
  
 
  
  
  
    
    
  
  
  task run_phase(uvm_phase phase);
    
    fork
      	begin
          	
          forever begin
            fifo1_h.get(a);
            a_cov =new a;
            cg1.sample();
            q1.push_back(a);
            
           // `uvm_info(get_type_name(),"got aaaaa",UVM_LOW)

          end
        end
      	
      	begin
          	forever begin
              fifo2_h.get(b);
              q2.push_back(b);
              b_cov =new b;
              cg2.sample();
            //  `uvm_info(get_type_name(),"got bbbbb",UVM_LOW)

            end
        end
      
      join  
    
    
  endtask  
  
   function void compare(bit[31:0] data1,bit[31:0] data2,bit[31:0] addr1,bit[31:0] addr2);
      	
      if(data1==data2)
        `uvm_info(get_type_name(),"succesful in data comparison",UVM_LOW)
      else
        `uvm_info(get_type_name(),"failed  in data comparison",UVM_LOW)
        
        if(addr1==addr2)
          `uvm_info(get_type_name(),"succesful in address comparison",UVM_LOW)
      else
        `uvm_info(get_type_name(),"failed  in address comparison",UVM_LOW)  
        
    endfunction
        
        
      function void check_data(src_xtn a,dst_xtn b);
      	
     if(a.hwrite)
        	begin
              case(a.hsize)
                	3'b000:begin
                      if(a.haddr[1:0]==2'b00)
                        compare(a.hwdata[7:0],b.pwdata[7:0],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b01)
                        compare(a.hwdata[15:8],b.pwdata[7:0],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b10)
                        compare(a.hwdata[23:16],b.pwdata[7:0],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b11)
                        compare(a.hwdata[31:24],b.pwdata[7:0],a.haddr,b.paddr);
                    end
                	3'b001:begin
                      if(a.haddr[1:0]==2'b00)
                        compare(a.hwdata[15:0],b.pwdata[15:0],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b10)
                        compare(a.hwdata[31:16],b.pwdata[15:0],a.haddr,b.paddr);
                    end
                	3'b010:begin
                       compare(a.hwdata,b.pwdata,a.haddr,b.paddr);
					end
              endcase
            end
      else 
        begin
              case(a.hsize)
                	3'b000:begin
                      if(a.haddr[1:0]==2'b00)
                        compare(a.hrdata[7:0],b.prdata[7:0],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b01)
                        compare(a.hrdata[7:0],b.prdata[15:8],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b10)
                        compare(a.hrdata[7:0],b.prdata[23:16],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b11)
                        compare(a.hrdata[7:0],b.prdata[31:24],a.haddr,b.paddr);
                    end
                	3'b001:begin
                      if(a.haddr[1:0]==2'b00)
                        compare(a.hrdata[15:0],b.prdata[15:0],a.haddr,b.paddr);
                      else if (a.haddr[1:0]==2'b10)
                        compare(a.hrdata[15:0],b.prdata[31:16],a.haddr,b.paddr);
                    end
                	3'b010:begin
                      compare(a.hrdata,b.prdata,a.haddr,b.paddr);
					end
              endcase
            end
    endfunction    
  
  
  function  void extract_phase(uvm_phase phase);
    
    super.extract_phase(phase);
    	
    	
    if(q1.size>=q2.size)
      	size=q2.size;
   else
     	size=q1.size;
    
    `uvm_info(get_type_name(),$sformatf("size=%0d,q1 size=%0d,q2 size=%0d",size,q1.size,q2.size),UVM_LOW)

    
     repeat(size)
      	begin
          a=q1.pop_front();
          b=q2.pop_front();
          check_data(a,b);
        end     
        
 	
      	
    
    
    
  
    
    
  endfunction  
  
  
  function void check_phase(uvm_phase phase);
    
    `uvm_info(get_type_name(),$sformatf("the coverage cg1 percenrtage is %0f",cg1.get_coverage),UVM_LOW)
    
    `uvm_info(get_type_name(),$sformatf("the coverage cg2  percenrtage is %0f",cg2.get_coverage),UVM_LOW)
    
  endfunction  

    
        	
                
                      
      
    
    
    
    
      	
    
  

endclass

class env extends uvm_env;

	`uvm_component_utils(env)

	env_config m_cfg;

	src_agent_top src_agnt_h[];

	dst_agent_top dst_agnt_h[];

	scoreboard sb_h[];

	


        function new(string name="",uvm_component parent);

                super.new(name,parent);

        endfunction

	
	function void build_phase(uvm_phase phase);
	
		if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
			`uvm_fatal(get_type_name(),"error from env")
	
		if(m_cfg.has_scoreboard)
			begin
				sb_h=new[m_cfg.no_of_agents];
				foreach(sb_h[i])
					sb_h[i]=scoreboard::type_id::create($sformatf("sb[%0d]",i),this);
			end
		
		if(m_cfg.has_src_agent)
			begin
				src_agnt_h=new[m_cfg.no_of_agents];
				
					foreach(src_agnt_h[i])
						begin
							uvm_config_db#(src_agent_config)::set(this,"*","src_agent_config",m_cfg.src_m_cfg[i]);
							src_agnt_h[i]=src_agent_top::type_id::create($sformatf("src_agnt_h[%0d]",i),this);
						end
			end
		
		   if(m_cfg.has_dst_agent)
                        begin
                                dst_agnt_h=new[m_cfg.no_of_agents];

                                        foreach(dst_agnt_h[i])
                                                begin
                                                        uvm_config_db#(dst_agent_config)::set(this,"*","dst_agent_config",m_cfg.dst_m_cfg[i]);
                                                        dst_agnt_h[i]=dst_agent_top::type_id::create($sformatf("dst_agnt_h[%0d]",i),this);
                                                end
                        end

		endfunction


		function void connect_phase(uvm_phase phase);
			
			foreach(sb_h[i])
				begin
					src_agnt_h[i].agnt_h.mon_h.ap.connect(sb_h[i].fifo1_h.analysis_export);
					dst_agnt_h[i].agnt_h.mon_h.ap.connect(sb_h[i].fifo2_h.analysis_export);	
				end
		endfunction
																	
	


endclass


