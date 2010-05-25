# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cia_session_id'
  def autorizo
                unless CcUsuario.find_by_id(session[:id])
                        redirect_to :controller=>"index",:action=>"index"
                        
                end

   end
   def float(string)
      if string.to_f.to_s==string
	  	 float=true
	  else
	  	 float=false
	  end
	  
   end
   #quitar formato de moneda
    def quitacoma(valor)
  		val=valor
		val=val.gsub(/[$]/,'')
		val=val.gsub(/[,]/,'')
		return val
  end 
  #para verificar el problema que encontre en el uso de flotante
  def errfloat(valorfloat)
  	@ftos=valorfloat.to_s
	if @ftos.index("e")!=nil
	   @valretorna=0.00
	else
	   @valretorna=valorfloat
	end
       return @valretorna
  end     
  #metodo sacar mes
  def mes(fecha,tipo)
  		a=fecha[0,fecha.index("-")]
		fecha=fecha[fecha.index("-")+1,fecha.length]
		m=fecha[0,fecha.index("-")]
		d=fecha[fecha.index("-")+1,fecha.length]
		vl=m.to_i
  		case vl
				when 1 then rm="Enero"
				when 2 then rm="Febrero"
				when 3 then rm="Marzo"
				when 4 then rm="Abril"
				when 5 then rm="Mayo"
				when 6 then rm="Junio"
				when 7 then rm="Julio"
				when 8 then rm="Agosto"
				when 9 then rm="Septiembre"
				when 10 then rm="Octubre"
				when 11 then rm="Noviembre"
				when 12 then rm="Diciembre"
		end
		if tipo.to_i==1
			fletra="#{d} de #{rm} de #{a}"
		end
		if tipo.to_i==2
			fletra="#{d}/#{m}/#{a}"
		end
		if tipo.to_i>2
			fletra="Tipo no valido..."
		end
		mes=fletra
  end
  
  
  #metodo para pasar de numero a letras
  
  def numlet(numero)
      #numero="1658323.40"
      @StrNumero=""
      @StrUnidades=""
      @StrDieces=""
      @StrDecenas=""
      @StrCienmil=""
      @StrNumLet=""
      @StrNumLet2=""
      @NumPos=0
      @StrDigito=""
      @StrDigito2=""
      @NumDig=0
      @StrCents=""
      
      #              1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
      @StrUnidades = "      UN    DOS   TRES  CUATROCINCO SEIS  SIETE OCHO  NUEVE "
      @StrDieces = "DIEZ      ONCE      DOCE      TRECE     CATORCE   QUINCE    DIECISEIS DIECISIETEDIECIOCHO DIECINUEVE"
      @StrDecenas = "                  VEINTE   TREINTA  CUARENTA CINCUENTASESENTA  SETENTA  OCHENTA  NOVENTA  "
      @StrCienmil = "            DOS   TRES  CUATROCINCO SEIS  SETE  OCHO  NOVE  "
      @StrNumLet = ""
      @NumPos = -1
        
      #StrNumero = Format(numero, "###########0.00")
      @StrNumero = sprintf("%0.2f",numero)
      @StrCents =@StrNumero[@StrNumero.length-2,@StrNumero.length] 
      
      
      @StrNumero = @StrNumero[0,@StrNumero.index(".")]
      
      @NumDig = @StrNumero.length
      if @NumDig < 12
        @StrNumero = (" " * (12 - @NumDig.to_i)) + @StrNumero
      end
      
      while @NumPos < 11
         @NumPos = @NumPos + 1
         @StrDigito = @StrNumero[@NumPos, 1]
         if ("-"<=>@strDigito)!=0
           if " 015".index(@StrDigito).nil?
             @StrNumLet = @StrNumLet + @StrCienmil[@StrDigito.to_i * 6 , 6] + "CIENTOS "
           else
             if (@StrNumero[@NumPos, 3]<=>"100")==0
                @StrNumLet = @StrNumLet + "CIEN "
             else
               if (@StrDigito<=>"5")==0
                @StrNumLet = @StrNumLet + "QUINIENTOS "
               end
               if (@StrDigito<=>"1")==0
                   @StrNumLet = @StrNumLet + "CIENTO "
               end
             end
           end
           
           @NumPos = @NumPos + 1
           #Verifica los dieces y unidades
           @StrDigito = @StrNumero[@NumPos, 1]
           @StrDigito2 = @StrNumero[@NumPos + 1, 1]
           
           if (@StrDigito<=>"1")>0
             @StrNumLet2 = @StrNumLet
             @StrNumLet = @StrNumLet + @StrDecenas[@StrDigito.to_i * 9, 9]
             if (@StrDigito2<=>"0")>0
               if (@StrDigito<=>"2")==0
                 @StrNumLet = @StrNumLet2 + "VEINTI"
               else
                 @StrNumLet = @StrNumLet + " Y "
               end
               @StrNumLet = @StrNumLet + @StrUnidades[@StrDigito2.to_i * 6, 6]
             end
           else
             if (@StrDigito<=>"1")==0
               @StrNumLet = @StrNumLet + @StrDieces[@StrDigito2.to_i * 10, 10]
             else
               if (@StrDigito2<=>"-")!=0
                 @StrNumLet = @StrNumLet + @StrUnidades[@StrDigito2.to_i * 6, 6]
               end
             end
           end
           @NumPos = @NumPos + 1
           if (@NumPos == 2 or @NumPos == 8) and ((@StrDigito2<=>" ")!=0)
             @StrNumLet = @StrNumLet + " MIL "
           else
             if @NumPos == 5 and ((@StrDigito2<=>" ")!=0)
               if numero.to_f >= 2000000
                 @StrNumLet = @StrNumLet + " MILLONES "
               else
                 @StrNumLet = @StrNumLet + " MILLON "
               end
             end
           end
        end
      
   end
     
    @StrNumLet = "**(" + @StrNumLet.strip + " PESOS " + @StrCents.strip + "/100 M.N.)**"
    numlet = @StrNumLet
  
  end

end
