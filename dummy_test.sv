`timescale 1ps / 1ps
`default_nettype none
`define BITS 16
`define DEPTH 16
`include "fifo.sv"

module Sim_fifo;

	// Inputs
	reg clk;
	reg rst;
	reg [`BITS-1:0] Din;
        reg push;
        reg pop;

	// Outputs
	wire [`BITS-1:0] Dout;
	wire pndng;
        wire full;

	// Instantiate the Unit Under Test (UUT)
      fifo_flops #(`DEPTH,`BITS) uut(
        .Din(Din),
        .Dout(Dout),
        .push(push),
        .pop(pop),
        .full(full),
        .pndng(pndng),
        .rst(rst),
        .clk(clk)
    );
	
    int clock_counter;

initial begin
	clk=0;
	rst = {1'b1};
        push =0;
        pop = 0;
        Din=0;
        clock_counter =0;
		
end

always #1 clk=~clk;   
always@(posedge clk)begin
  if(clock_counter > 4) begin
    rst = 0;
    prueba(); // LLama a una funcion prueba
  end else begin
    rst=1;
    clock_counter= clock_counter+1;	
  end
end
 int ciclo =0;
 int dato =0;
 
  task prueba();		//funcion prueba

      if(full==1)begin // Cambia si la fifo está llena
        ciclo=1;
      end

  case(ciclo)
    0: begin 		// ciclo de llenado de fifo
      rst = 0;
      push = ~push;
      pop=0;
      Din = dato;
      if(push==1)begin
        $display("at %g pushed data: %g count %g",$time,dato,Sim_fifo.uut.count);
      end else begin
        dato=dato+1;
      end
    end
    1: begin		//ciclo de vaciado 
      rst = 0;
      push =0;
      pop=~pop;
      Din = dato;
      if(pop==1)begin
        $display("at %g poped data: %g count: %g",$time,Dout,Sim_fifo.uut.count);
      end
      if(pndng == 0)begin
        $finish;
      end
    end
    default:begin
      $display("at %g default state %g",$time,ciclo);
      $finish;
    end
  endcase
  endtask

endmodule

