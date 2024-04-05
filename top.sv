// Code your design here
import uvm_pkg::*;

`include "uvm_macros.svh"
`include "rtl.v"
`include "master_if.sv"
`include "slave_if.sv"
`include "test_pkg.sv"

import test_pkg::*;

module top;

	bit clk;
	
	master_if vif1(clk);
	
	slave_if vif2(clk);

	rtl_top dut(clk,vif1.hresetn,vif1.htrans,vif1.hsize,vif1.hreadyin,vif1.hwdata,vif1.haddr,vif1.hwrite,vif2.prdata,vif1.hrdata,vif1.hresp,vif1.hreadyout,vif2.pselx,vif2.pwrite,vif2.penable,vif2.paddr,vif2.pwdata);

	initial begin

		forever #10 clk=~clk;
	end

	initial begin
      $dumpfile("file.vcd");
      	
      $dumpvars;
    end  
      	
    initial begin
      	#1000;
      	$finish;
    end


	initial begin

		uvm_config_db#(virtual master_if)::set(null,"*","vif1",vif1);
		
		uvm_config_db#(virtual slave_if)::set(null,"*","vif2",vif2);
		
      run_test("test");
	end
endmodule

