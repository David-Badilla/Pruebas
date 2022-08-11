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
	int NumeroPrueba;
initial begin
	clk=0;
	rst = {1'b1};
        push =0;
        pop = 0;
        Din=0;
        clock_counter=0;
        
		NumeroPrueba=0;
		
end

always #1 clk=~clk;   
always@(posedge clk)begin
  if(clock_counter > 4) begin	//Verifica si ya pasaron los 4 ciclos de reinicio
    rst = 0;
	if (NumeroPrueba==0)begin //Revisa variables de control que cabian progresivamente
    	prueba(); // LLama a una funcion prueba
	end
    if(NumeroPrueba==1)begin
    	overflow();
    	end
	if (NumeroPrueba==2)begin
		underflow();
		end
	if(NumeroPrueba==3)begin
		pushpop();
		end
	if(NumeroPrueba==4)begin
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
  task prueba();		//funcion prueba Profe

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
      if(pndng == 0)begin //La prueba actual finaliza
		NumeroPrueba=1; //Actualiza para hacer una siguiente prueba
      	
      	dato=0;	//Reinicio de variables importantes en las siguientes pruebas
      	ciclo=0;
      	pop=0;
      	
      	
      	rst=1;	//Cambio para aplicar reset despues de acabar esta prueba
      	clock_counter=0; //reinicio del contador para aplicar reset por 4 ciclos
        $display("-------PRUEBA OVERFLOW------40 datos seguidos-------------------------------"); //Imprime en terminal la siguiente prueba a realizar - la coloqué aqui para que no se repitiera en cada ciclo
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
		NumeroPrueba=2; //Actualiza para hacer una siguiente prueba
		
		dato=0; //Reinicio variable dato
		pop=0; //por fallos en el inicio de la siguiente prueba
		push=0;
		
		rst=1; //Variables para aplicar reset
		clock_counter=0;
		$display("-------PRUEBA UNDERFLOW---------20 veces pop---------------------------");//Imprime el titulo de la siguiente prueba 
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
  		
  	if (dato==20)begin //detiene la prueba luego de introducir 20 datos solo porque si
  		NumeroPrueba=3; //Actualiza para hacer una siguiente prueba
  		
		dato=0;//reinicio de dato para la siguiente prueba
		push=0;
		pop=0;
		
		rst=1;	//Para aplicar un reset al finalizar esta prueba
		clock_counter=0;	//reinicia contador para aplicar reset por 4 ciclos
		$display("-------PRUEBA PUSH POP-------------------------------------"); //Imprime el siguiente titulo
	end
	
  endtask
  
 //--------------------PRUEBA PUSH POP al mismo tiempo-------------------------------------------------
  task pushpop();
  	rst = 0;
  	push = ~push;
  	pop =~ pop;
  	
  	if(push==1 && pop==1)begin
	    $display("at %g pushed data: %g poped data: %g count %g",$time,dato,Dout,Sim_fifo.uut.count);
	  end else begin
	    dato=dato+1;
	  end
  	  
      
     if(dato == 17)begin	//Para detener la prueba luego de 17 datos
		NumeroPrueba=4; //Actualiza para hacer una siguiente prueba
		
		ciclo=0;
		dato=0;
		push=0;
		pop=0;
		
		rst=1;		//Aplicar el reset antes de iniciar la siguiente prueba
		clock_counter=0;	//Reiniciar el contador para aplicar reset por 4 ciclos
		$display("-------PRUEBA PUSH POP INTERCALADO-------------------------");
	  end
  	
  	
  		
		
  endtask
 //--------------------PRUEBA PUSH POP INTERCALADO-------------------------------------------------
  task pushpopinter();
  
  if(dato == 17)begin //Detiene la prueba luego de n datos escritos en push
    $finish;
        
  end
  
  case(ciclo)
    0: begin 		// ciclo de llenado de push
      rst = 0;
      push = ~push;
      pop=0;
      Din = dato;
      if(push==1)begin
        $display("at %g pushed data: %g count %g",$time,dato,Sim_fifo.uut.count);
      end else begin
        dato=dato+1;
        ciclo=~ciclo;		//Cambia la variable ciclo para que en el siguiente ciclo sea de pop
      end
    end
    1: begin		//ciclo de pop
      rst = 0;
      push = 0;
      pop=~pop;
      Din = dato;
      if(pop==1)begin
        $display("at %g poped data: %g count: %g",$time,Dout,Sim_fifo.uut.count);
        ciclo=~ciclo;		//Cambia la variable ciclo para que en el siguiente ciclo sea de push
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

