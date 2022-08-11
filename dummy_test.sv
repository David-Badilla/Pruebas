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
    
	int Cerofin;
    int Primfin;
    int Segfin;
    int Terfin;
    int Cuarfin;
    

initial begin
	clk=0;
	rst = {1'b1};
        push =0;
        pop = 0;
        Din=0;
        clock_counter =0;
        
        Cerofin=1;
		Primfin=0;
		Segfin=0;
		Terfin=0;
		Cuarfin=0;
end

always #1 clk=~clk;   
always@(posedge clk)begin
  if(clock_counter > 4) begin
    rst = 0;
	if (Cerofin==1)begin //Revisa variables de control que cabian progresivamente
    	prueba(); // LLama a una funcion prueba
	end
    if(Primfin==1)begin
    	overflow();
    	end
	if (Segfin==1)begin
		underflow();
		end
	if(Terfin==1)begin
		pushpop();
		end
	if(Cuarfin==1)begin
		pushpopinter();
		end
  end else begin
    rst=1;
    clock_counter= clock_counter+1;	
  end
end
 int ciclo =0;
 int dato =0;
 //--------------PRUEBA LLENADO Y VACIADO-------------------------------------------------------
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
      push = 0;
      pop=~pop;
      Din = dato;
      if(pop==1)begin
        $display("at %g poped data: %g count: %g",$time,Dout,Sim_fifo.uut.count);
      end
      if(pndng == 0)begin
		
		Cerofin=0;//Cambio de variables de control
      	Primfin=1;
      	
      	dato=0;
      	ciclo=0;
      	
      	
      	rst=1;	//Cambio para aplicar reset despues de acabar esta prueba
      	clock_counter=0; //reinicio del contador para aplicar reset por 4 ciclos
        $display("-------PRUEBA OVERFLOW------40 datos seguidos-------------------------------");
      end
    end
    default:begin
      $display("at %g default state %g",$time,ciclo);
      $finish;
    end
  endcase
  endtask
 //--------------PRUEBA OVERFLOW-------------------------------------------------------
  task overflow();
  
	  rst = 0;
	  push = ~push;
	  pop=0;
	  Din = dato;
	  if(push==1)begin
	    $display("at %g pushed data: %g count %g Salida %g",$time,dato,Sim_fifo.uut.count,Dout);
	  end else begin
	    dato=dato+1;
	  end
  	  		
	  if(dato==40)begin // para detener la prueba luego de 40 datos
	  	Primfin=0;  		
		Segfin=1;
		dato=0; //Reinicio variable dato
		pop=0; //por fallos en el inicio de la siguiente prueba
		
		rst=1; //Variables para aplicar reset
		clock_counter=0;
		$display("-------PRUEBA UNDERFLOW---------20 veces pop---------------------------");
	  end			
  
  endtask
  
  //------------------PRUEBA UNDERFLOW---------------------------------------------------
  task underflow();
  	rst = 0;
    push = 0;
    pop=~pop;
    Din = dato;
    if(pop==1)begin
        $display("at %g poped data: %g count: %g",$time,Dout,Sim_fifo.uut.count);
        dato=dato+1;
      end
  		
  	if (dato==20)begin //detiene la prueba luego de introducir 20 datos
  		
  		Segfin=0;// variables de control para iniciar la siguiente prueba
		Terfin=1;
		
		
		dato=0;//reinicio de dato para la siguiente prueba
		push=0;
		pop=0;
		
		rst=1;	//Para aplicar un reset al finalizar esta prueba
		clock_counter=0;	//reinicia contador para aplicar reset por 4 ciclos
		$display("-------PRUEBA PUSH POP-------------------------------------");
	end
	
  endtask
  
 //--------------------PRUEBA PUSH POP-------------------------------------------------
  task pushpop();
  	rst = 0;
  	push = ~push;
  	pop=~pop;
  	
  	if(push==1 && pop==1)begin
	    $display("at %g pushed data: %g poped data: %g count %g",$time,dato,Dout,Sim_fifo.uut.count);
	  end else begin
	    dato=dato+1;
	  end
  	
  	
  	
 
      
      
     if(dato == 17)begin
		Terfin=0;	//Variables de control para continuar con la siguiente prueba
		Cuarfin=1;
		ciclo=0;
		dato=0;
		rst=1;		//Aplicar el reset antes de iniciar la siguiente prueba
		clock_counter=0;	//Reiniciar el contador para aplicar reset por 4 ciclos
		$display("-------PRUEBA PUSH POP INTERCALADO-------------------------");
	  end
  	
  	
  		
		
  endtask
 //--------------------PRUEBA PUSH POP INTERCALADO-------------------------------------------------
  task pushpopinter();
  
  if(dato == 17)begin
    $finish;
        
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
        ciclo=~ciclo;
      end
    end
    1: begin		//ciclo de vaciado 
      rst = 0;
      push = 0;
      pop=~pop;
      Din = dato;
      if(pop==1)begin
        $display("at %g poped data: %g count: %g",$time,Dout,Sim_fifo.uut.count);
        ciclo=~ciclo;
      end
    end
    
    
    default:begin
      $display("at %g default state %g",$time,ciclo);
      $finish;
    end
  endcase

  		
  
  $finish;
  endtask

endmodule

