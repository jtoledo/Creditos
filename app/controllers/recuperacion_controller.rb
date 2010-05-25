class RecuperacionController < ApplicationController
   before_filter :autorizo,:except=> :index
  include AjaxScaffold::Controller
   include ActionView::Helpers::NumberHelper
   include ActionView::Helpers::PrototypeHelper
   include ActionView::Helpers::JavaScriptHelper
   include ActionView::Helpers::TagHelper
  after_filter :clear_flashes
  before_filter :update_params_filter
  
  def update_params_filter
    update_params :default_scaffold_id => "vr_cc_credito", :default_sort => nil, :default_sort_direction => "asc"
  end
  def index
    redirect_to :action => 'list'
  end
  def return_to_main
    # If you have multiple scaffolds on the same view then you will want to change this to
    # to whatever controller/action shows all the views 
    # (ex: redirect_to :controller => 'AdminConsole', :action => 'index')
    redirect_to :action => 'list'
  end

  def list
  #resete el hash para cobranza grupal
  @cmpse="pgpo#{session[:id]}"
  session["#{@cmpse}"]={}
  end
  
  # All posts to change scaffold level variables like sort values or page changes go through this action
  def component_update
    @show_wrapper = false # don't show the outer wrapper elements if we are just updating an existing scaffold 
    if request.xhr?
      # If this is an AJAX request then we just want to delegate to the component to rerender itself
      component
    else
      # If this is from a client without javascript we want to update the session parameters and then delegate
      # back to whatever page is displaying the scaffold, which will then rerender all scaffolds with these update parameters
      return_to_main
    end
  end

  def component
  	
	if request.post?
	  
	 begin
	 	if params[:cliente][:id].strip.empty?!=true and params[:cliente][:grupo].strip.empty?!=true
			#filtra por cliente y grupo
			session["recu#{session[:id]}"]="where entregado_boo=true and grupo='#{params[:cliente][:grupo].upcase}' and cliente like '%#{params[:cliente][:id].upcase}%'"
				
		else
			#busca solo cliente
			if params[:cliente][:id].strip.empty?!=true
			 	  session["recu#{session[:id]}"]="where entregado_boo=true and cliente like '%"+params[:cliente][:id].upcase+"%'"
			else
			   if params[:cliente][:grupo].strip.empty?!=true
			    	session["recu#{session[:id]}"]="where entregado_boo=true and grupo='#{params[:cliente][:grupo].upcase}'"
			   end	
			end
			
		end
	  rescue Exception => err
	  ensure 	
	  end
	 else
	 	session["recu#{session[:id]}"]="where entregado_boo=true"
	 end 
	 @filtro=session["recu#{session[:id]}"] 
    @show_wrapper = true if @show_wrapper.nil?
    @sort_sql = VrCcCredito.scaffold_columns_hash[current_sort(params)].sort_sql rescue nil
    @sort_by = @sort_sql.nil? ? "#{VrCcCredito.table_name}.#{VrCcCredito.primary_key} asc" : @sort_sql  + " " + current_sort_direction(params)
    @paginator, @vr_cc_creditos = paginate(:vr_cc_creditos,:select=>"id,folio,grupo,cliente,monto,f_aprobacion,f_ministracion,idsolgrupo", :joins=>"#{@filtro}",:order => @sort_by, :per_page => default_per_page)
    
    render :action => "component", :layout => false
  end

  def new
    @vr_cc_credito = VrCcCredito.new
    @successful = true

    return render(:action => 'new.rjs') if request.xhr?

    # Javascript disabled fallback
    if @successful
      @options = { :action => "create" }
      render :partial => "new_edit", :layout => true
    else 
      return_to_main
    end
  end
  
  def create
    begin
      @vr_cc_credito = VrCcCredito.new(params[:vr_cc_credito])
      @successful = @vr_cc_credito.save
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'create.rjs') if request.xhr?
    if @successful
      return_to_main
    else
      @options = { :scaffold_id => params[:scaffold_id], :action => "create" }
      render :partial => 'new_edit', :layout => true
    end
  end

  def edit
    begin
      @vr_cc_credito = VrCcCredito.find(params[:id])
      @successful = !@vr_cc_credito.nil?
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'edit.rjs') if request.xhr?

    if @successful
      @options = { :scaffold_id => params[:scaffold_id], :action => "update", :id => params[:id] }
      render :partial => 'new_edit', :layout => true
    else
      return_to_main
    end    
  end

  def update
    begin
      @vr_cc_credito = VrCcCredito.find(params[:id])
      @successful = @vr_cc_credito.update_attributes(params[:vr_cc_credito])
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'update.rjs') if request.xhr?

    if @successful
      return_to_main
    else
      @options = { :action => "update" }
      render :partial => 'new_edit', :layout => true
    end
  end

  def destroy
    begin
      @successful = VrCcCredito.find(params[:id]).destroy
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'destroy.rjs') if request.xhr?
    
    # Javascript disabled fallback
    return_to_main
  end
  
  def cancel
    @successful = true
    
    return render(:action => 'cancel.rjs') if request.xhr?
    
    return_to_main
  end
  #-----------------------------------------------------------------------------------------------------------------
  #Modulo de condonaciones
  def condonacion
  		@parametro=params[:id]
		#Carga fecha actual
		@seldia=Time.now.day
		@selmes=Time.now.month
		@selanio=Time.now.year
		@fecha=@selanio.to_s+"-"+@selmes.to_s+"-"+@seldia.to_s
		
		@datos=VrCcCredito.find(@parametro)
		
		#actualiza pagos
		if Date::valid_civil?(@selanio.to_i, @selmes.to_i, @seldia.to_i)!=nil
			@sqlupdatepag="select * from cc_calcular_dias_vencidos_pagares(#{@datos.idcliente},'#{@fecha}')"
			@updte=VrCcCredito.find_by_sql(@sqlupdatepag)
			flash[:notice]=""
		else
			flash[:notice]="<font color=red>La fecha no es valida, verifique!</font>"
		end
		@sqlcre="SELECT folio,f_ministracion,monto,cc_calcular_monto_actual(idcredito) as montoActual,fecha_hasta,promotor,idcredito,idsolicitud,grupo,"
		@sqlcre+="fecha_vencimiento,cliente,f_aprobacion FROM v_cc_creditos c WHERE idcliente=#{@datos.idcliente} and idcredito=#{@parametro} and entregado_boo"
		@datocre=VrCcCredito.find_by_sql(@sqlcre)
		@sqlpag="SELECT * from (select fecha_pagar,idcredito,dias_vencido,cns_pagare,pagado from v_cc_pagares	where idcredito = #{@parametro} order by fecha_pagar) as cTmp"
		@datopagare=VrCcCredito.find_by_sql(@sqlpag)
  		 @dia=[]
		 @mes=[]
		 @anio=[]
		 @anat=Time.now.year
		 @anat=@anat.to_i-10
		 for @i in (1..31)
			@anio[@i-1]=@anat
			@dia[@i-1]=@i
			if @i<=12
				@mes[@i-1]=@i
			end
				
			@anat=@anat+1
		 end
		#opciones de pago
		@formapago=VrCcCredito.find_by_sql("select forma,idforma from cc_formas_pago order by 1")
		 @oppago=[[]]
		 @oppago[0]="<Seleccion una cuenta>","0"
		 count=1
		 for el in @formapago
			@oppago[count]=el.forma,el.idforma
			count+=1
		 end
		 #inicializar el hash para almacenar
		 @cmpse="pind#{session[:id]}"
		 session["#{@cmpse}"]={}

  end
  
  def cargapagare
  	 @valor=params[:id]
	 if request.post?
	 	session[:notice]=""
	 end
	 @cheque=@valor[0,@valor.index("-")].to_s
	 @parametro=@valor[@valor.index("-")+1,(@valor.index("*")-(@valor.index("-")+1))].to_s
	 @ncheque=@valor[@valor.index("*")+1,@valor.length].to_s
	 #esto es para cargar los concepto menores a 14 capital y interes moratorio e interes normal
	 @sqldetpag="select cargo1::varchar(40),monto1,COALESCE((select monto from cc_condonaciones_sugeridas where	idconcepto=idconcepto1),0) as "
	 @sqldetpag+="condonar,idconcepto1,cns_pagare1,cns_otro_cargo1,pagado1,prioridad1 from 	cc_conceptos_condonar(#{@parametro}) as c where cns_pagare1=#{@cheque} and idcargo1<=14 order by"
	 @sqldetpag+=" cns_pagare1,prioridad1"
	 @detallepag=VrCcCredito.find_by_sql(@sqldetpag)
	 
	 #esto es para sacar el gasto de cobranza global
	 @sqlgcob="select 1 as cv,sum(monto1) as monto1,'GASTOS DE COBRANZA' as cargo1,"
	 @sqlgcob+=" (select idconcepto1 from 	cc_conceptos_condonar(#{@parametro}) as c where" 
 	 @sqlgcob+=" cns_pagare1=#{@cheque} and idcargo1>14 order by cns_pagare1,prioridad1 limit 1)"
  	 @sqlgcob+=" as idconcepto1 from cc_conceptos_condonar(#{@parametro}) where cns_pagare1=#{@cheque} and idcargo1>14  group by cv"
	 @detallecob=VrCcCredito.find_by_sql(@sqlgcob)
	 
	 # detalle de lo que esta pagado
	 @sqlpagado="select distinct cargo,idcargo,prioridad,cns_pagare,fecha,idconcepto,idcredito,capital,monto1 from ccr_obtiene_conceptos_pagados,"
	 @sqlpagado+="ccr_agrupa_pagado(#{@parametro},#{@cheque}) gru where idcredito=#{@parametro} and cns_pagare=#{@cheque} and gru.idcargo1=idcargo order by prioridad"
	 @detallepagado=VrCcCredito.find_by_sql(@sqlpagado)
	 
   
     @credito=VrCcCredito.find(@parametro)
	 @formapago=VrCcCredito.find_by_sql("select forma,idforma from cc_formas_pago order by 1")
	 @oppago=[[]]
	 @oppago[0]="<Seleccion una cuenta>","0"
	 count=1
	 for el in @formapago
	    @oppago[count]=el.forma,el.idforma
		count+=1
	 end

  end
  def aplicamov
  		@credito=params[:id]
		@cheque=params[:pago][:cheque]
		@importe=params[:pago][:ficha].to_f
		#primero vamos a verificar si concide la cantidad con distribuida con la ficha
		@referencia=params[:pago][:referencia]
		@tpago=params[:pago][:modo]
		@fecha=params[:pago]["fecha(3i)"]+"-"+params[:pago]["fecha(2i)"]+"-"+params[:pago]["fecha(1i)"]
		if @referencia.strip.empty? or @importe<=0 or @tpago.to_i==0
			@notice="<font color=red>Verifique los siguientes datos: Referencia no debe ser vacia,importe debe ser mayor a 0 y debe seleccionar el banco</font>"
		else
				@cmpse="pind#{session[:id]}"
				@hash=session["#{@cmpse}"]
				@sum=0.00
				for pagare in @hash
					for concepto in @hash["#{pagare[0]}"]
						@sum+=@hash["#{pagare[0]}"]["#{concepto[0]}"].to_f
					end
				 end
				#termina la validacion del hash
				@sum=@sum.to_s.to_f
				@importe=@importe.to_s.to_f
				if @importe==@sum
					#Guardar los datos
					#verificacion si es cobranza o condonacion
					if @tpago.to_i==23
					  #condonacion
						@tipocobro=false
					else
						#cobranza
						@tipocobro=true
					end

					@pcont=""
					#iniciando la transaccion de aplicacion de movimientos
					@tran=VrCcCredito.find_by_sql("begin")
					@sqlmovimiento="insert into cc_movimientos values (default,'#{@fecha}','-----',#{@sum.to_f},#{@tipocobro},#{@tpago.to_i},'#{@referencia}')returning idmovimiento"
					@movimiento=VrCcCredito.find_by_sql(@sqlmovimiento)
					@idmov=@movimiento[0].idmovimiento.to_i
					for pagare in @hash
						@capital=0
						@normal=0
						@moratorio=0
						@cobranza=0
						for concepto in @hash["#{pagare[0]}"]
							    #verificar que concepto es 
								@sqlcon="select idcargo from cc_otros_cargos where idcredito = #{@credito} "
								@sqlcon+="and cns_pagare = #{pagare[0]} and idconcepto=#{concepto[0]}"
								@cargos=VrCcCredito.find_by_sql(@sqlcon)
								if @cargos.length>0
									if @cargos[0].idcargo.to_i>14
										@cobranza=@hash["#{pagare[0]}"]["#{concepto[0]}"].to_f
										
									else
									    case @cargos[0].idcargo.to_i
											when 5 then
												 @moratorio=@hash["#{pagare[0]}"]["#{concepto[0]}"].to_f	
											when 6 then
												 @normal=@hash["#{pagare[0]}"]["#{concepto[0]}"].to_f
											
										end
									end
									
								else
									#no encontro ningu registro es capital
									@capital=@hash["#{pagare[0]}"]["#{concepto[0]}"].to_f
								end
								
								
							end
							#aqui va la ejecucion de la funcion de guardado ccr_registra_mov
							@execfuncion="select * from ccr_registrar_movgpo("
							@execfuncion+="#{@credito},#{pagare[0]},#{@tipocobro},#{@capital},#{@normal},"
							@execfuncion+="#{@moratorio},#{@cobranza},0,'#{@referencia}',#{@tpago},'#{@fecha}',#{@idmov})"
							#validar si borramos la distribucion en el pagare
							if @capital>0 or @normal>0 or @moratorio>0 or @cobranza>0
								@resul=VrCcCredito.find_by_sql(@execfuncion)
                                                 end
							
					end
					#genera la poliza
					@resul=VrCcCredito.find_by_sql("select cc_contabilizar_movimiento(#{@idmov})")
					@tran=VrCcCredito.find_by_sql("commit")
					#termina la transaccion
					session["#{@cmpse}"]={}
					@notice="<h3><font color=blue>Los datos fueron guardados correctamente..</h3></font>"
				else
					@notice="<font color=red>La cantidad distribuida no coincide con el importe de la ficha... verifique#{@importe}==[#{@sum}]</font>"
				end
				
		end
	render :text=>@notice
  end
  
  def guardapag
  		@idcredito=params[:id]
		@cheque=params[:pago][:cheque]
		@cmpse="pind#{session[:id]}"
	    @hash=session["#{@cmpse}"]
		@tamano=params[:concepto].length
		@arrconcepto=Array(params[:concepto])
		@i=0
		@texto=""
		while @i<@tamano 
			el=Array(@arrconcepto[@i])
			if @hash.has_key?("#{@cheque}")
			    
					@hash["#{@cheque}"]["#{el[0]}"]="#{el[1]}"
			else
			   @hash["#{@cheque}"]={}
			   @hash["#{@cheque}"]["#{el[0]}"]="#{el[1]}"
			end
			@i+=1
		end
		
		#checa la sumatoria del hash
		@cmpse="pind#{session[:id]}"
		@hash=session["#{@cmpse}"]
		@sum=0.00
		for pagare in @hash
			for concepto in @hash["#{pagare[0]}"]
				@sum+=@hash["#{pagare[0]}"]["#{concepto[0]}"].to_f
			end
		end
		#termina la sumatoria del hash
		render :text=>"<script languaje=javascript>var upd=document.getElementById('suco');upd.value="+@sum.to_s+"</script><font color=blue>#{@texto} Guardado satisfactoriamente...</font>"
		
  end
  
def distriind
 @parametro=params[:id] 	
 @ficha=params[:dist][:ficha].to_f
 @fecha=params[:dist][:fecha]
 @anio=@fecha[0,@fecha.index("-")]
 @rfecha=@fecha[@fecha.index("-")+1,@fecha.length]
 @mes=@rfecha[0,@rfecha.index("-")]
 @dia=@rfecha[@rfecha.index("-")+1,@rfecha.length]
 if Date::valid_civil?(@anio.to_i, @mes.to_i, @dia.to_i)!=nil
	@valficha=@ficha.to_f
	@datos=VrCcCredito.find(@parametro)
	if @valficha<=0
			 
			@html="<font color=blue>Los dias de vencimiento fue actualizada deacuerdo a la fecha #{@fecha}</font>"
			@html+="<table width='30%'><th><font color='#FFFFFF' face='bold 14px arial, sans-serif'>No.</th><th><font color='#FFFFFF' face='bold 14px arial, sans-serif'>Fhecha a pagar </th><th><font color='#FFFFFF' face='bold 14px arial, sans-serif'>Dias vencidos</th>"
			@sqlupdatepag="select * from cc_calcular_dias_vencidos_pagares(#{@datos.idcliente},'#{@fecha}')"
			@updte=VrCcCredito.find_by_sql(@sqlupdatepag)
			@sqlpag="SELECT * from (select fecha_pagar,dias_vencido,idcredito,cns_pagare,pagado from v_cc_pagares	where "
			@sqlpag+="idcredito = #{@parametro} order by fecha_pagar) as cTmp"
			@datopagare=VrCcCredito.find_by_sql(@sqlpag)
			cn=1
			for el in @datopagare
			 	#verificar si esta pagado el cheque
			   @sqlbusca="select cargo1::varchar(40),idcargo1,monto1,COALESCE((select monto from cc_condonaciones_sugeridas where "
			   @sqlbusca+="idconcepto=idconcepto1),0) as condonar,idconcepto1,cns_pagare1,cns_otro_cargo1,pagado1,prioridad1 from "
			   @sqlbusca+="cc_conceptos_condonar(#{el.idcredito}) as c where cns_pagare1=#{el.cns_pagare}  order by cns_pagare1,prioridad1"
			   @pagado=VrCcCredito.find_by_sql(@sqlbusca) 	
			   if @pagado.length<=0
					st="<font color=red>*</font>"
			   else
					st=""
			   end
			   @html+="<tr><td>#{cn}</td><td>"
			   @html+=link_to_remote el.fecha_pagar+st,{ :url => {:action=>"cargapagare",:id=>"#{el.cns_pagare}-#{@parametro}*#{cn}"},:update => "preview"}
			   @html+="</td><td>#{el.dias_vencido}</td></tr>"
			cn+=1
		  end
		 @html+="</table>"
		render :text=>@html
	end
	
	@suma=0.00
   	@sqlupdatepag="select * from cc_calcular_dias_vencidos_pagares(#{@datos.idcliente},'#{@fecha}')"
	@updte=VrCcCredito.find_by_sql(@sqlupdatepag)
	@sqlpag="SELECT * from (select fecha_pagar,dias_vencido,idcredito,cns_pagare,pagado from v_cc_pagares	where "
	@sqlpag+="idcredito = #{@parametro} order by fecha_pagar) as cTmp"
	@datopagare=VrCcCredito.find_by_sql(@sqlpag)
	#cargar los datos
			@html="<table width='30%'><th><font color='#FFFFFF' face='bold 14px arial, sans-serif'>No.</th><th><font color='#FFFFFF' face='bold 14px arial, sans-serif'>Fhecha a pagar </th><th><font color='#FFFFFF' face='bold 14px arial, sans-serif'>Dias vencidos</th>"
			cn=1
			for el in @datopagare
			 	#verificar si esta pagado el cheque
			   @sqlbusca="select cargo1::varchar(40),idcargo1,monto1,COALESCE((select monto from cc_condonaciones_sugeridas where "
			   @sqlbusca+="idconcepto=idconcepto1),0) as condonar,idconcepto1,cns_pagare1,cns_otro_cargo1,pagado1,prioridad1 from "
			   @sqlbusca+="cc_conceptos_condonar(#{el.idcredito}) as c where cns_pagare1=#{el.cns_pagare}  order by cns_pagare1,prioridad1"
			   @pagado=VrCcCredito.find_by_sql(@sqlbusca) 	
			   if @pagado.length<=0
					st="<font color=red>*</font>"
			   else
					st=""
			   end
			   @html+="<tr><td>#{cn}</td><td>"
			   @html+=link_to_remote el.fecha_pagar+st,{ :url => {:action=>"cargapagare",:id=>"#{el.cns_pagare}-#{@parametro}*#{cn}"},:update => "preview"}
			   @html+="</td><td>#{el.dias_vencido}</td></tr>"
			cn+=1
		  end
		 @html+="</table>"
		
	#distribucion del pago creando un hash para el almacenamiento temporal de los pagares
	@cmpse="pind#{session[:id]}"
	session["#{@cmpse}"]={}
	for pag in @datopagare
		  
		  begin		
			if session["#{@cmpse}"].has_key?("#{pag.cns_pagare}")
					@validahash=true
			else
					@validahash=false
			end
		  rescue Exception => err
			@validahash=false
		  ensure
		  end
		  if @validahash!=true
		    if session["#{@cmpse}"].has_key?("#{pag.cns_pagare}")!=true
		  		session["#{@cmpse}"]["#{pag.cns_pagare}"]={}
			end
			
			@sqldetpag="select cargo1::varchar(40),idcargo1,monto1,idcargo1,COALESCE((select monto from cc_condonaciones_sugeridas"
			@sqldetpag+=" where	idconcepto=idconcepto1),0) as condonar,idconcepto1,cns_pagare1,"
			@sqldetpag+="cns_otro_cargo1,pagado1,prioridad1 from cc_conceptos_condonar(#{@parametro}) as c where "
			@sqldetpag+="cns_pagare1=#{pag.cns_pagare} order by cns_pagare1,prioridad1"
	 		@detallepag=VrCcCredito.find_by_sql(@sqldetpag)
			
			for det in @detallepag
				 
				 if det.idcargo1.to_i==6 or det.idcargo1.to_i== -1
		  		 	if errfloat(@ficha.to_f)>0
						if @ficha.to_f > det.monto1.to_f
						   @ficha=@ficha.to_f-det.monto1.to_f
						   @monto=det.monto1.to_f
						else
						   if @ficha.to_f<=det.monto1.to_f
						      @monto=@ficha.to_f
						      @ficha=0.00 		
						   end
						end
						session["#{@cmpse}"]["#{pag.cns_pagare}"]["#{det.idconcepto1}"]="#{@monto}"
						@suma+=@monto.to_f
						
					end
				 end
			  end
			
		 end
	end
	if @valficha>0
			@htm="<font color=blue>La cantidad de #{number_to_currency(@valficha)} fue distribuida Quedando un saldo a favor de #{number_to_currency(@ficha)} </font> <br>"+@html		
		  render :text=>@htm
	end
#termina la validacion  de la fecha	
else 
	render :text=>"<font color=red size='3'>La Fecha es incorrecta #{@fecha}, verifique!<br/>Para ver los pagares selecciona una fecha correcta y actualiza</fornt>"
end

end

  
  #-------------------------------------------------------------------------------------------------------------------------
  #modulo de gastos
  def gastos
  		@parametro=params[:id]
		@datos=VrCcCredito.find(@parametro)
		@sqlcre="SELECT folio,f_ministracion,monto,cc_calcular_monto_actual(idcredito) as montoActual,fecha_hasta,promotor,idcredito,idsolicitud,grupo,"
		@sqlcre+="fecha_vencimiento,cliente,f_aprobacion FROM v_cc_creditos c WHERE idcliente=#{@datos.idcliente} and entregado_boo"
		@datocre=VrCcCredito.find_by_sql(@sqlcre)
		@sqlpag="SELECT * from (select fecha_pagar,dias_vencido,idcredito,cns_pagare,pagado from v_cc_pagares	where idcredito = #{@parametro} order by fecha_pagar) as cTmp"
		@datopagare=VrCcCredito.find_by_sql(@sqlpag)
  end
  
  def cargagasto
  	 @valor=params[:id]
	 if request.post?
	 	session[:noticeg]=""
	 end
	 @cheque=@valor[0,@valor.index("-")].to_s
	 @parametro=@valor[@valor.index("-")+1,(@valor.index("*")-(@valor.index("-")+1))].to_s
	 @ncheque=@valor[@valor.index("*")+1,@valor.length].to_s
	 @sqldetpag="select cargo1::varchar(40),monto1,COALESCE((select monto from cc_condonaciones_sugeridas where	idconcepto=idconcepto1),0) as "
	 @sqldetpag+="condonar,idconcepto1,cns_pagare1,cns_otro_cargo1,pagado1,prioridad1 from 	cc_conceptos_condonar(#{@parametro}) as c where cns_pagare1=#{@cheque} order by"
	 @sqldetpag+=" cns_pagare1,prioridad1"
	 @detallepag=VrCcCredito.find_by_sql(@sqldetpag)
	 @sqldetgasto="select fecha,cargo,monto,pagado from v_cc_otros_cargos_creditos where idtipo = 1 and cns_pagare=#{@cheque} AND idcredito = #{@parametro} order by idtipo"
	 @detgasto=VrCcCredito.find_by_sql(@sqldetgasto)
	 
	 @credito=VrCcCredito.find(@parametro)
	 @formapago=VrCcCredito.find_by_sql("select cargo,idcargo,idcuenta,prioridad,con_iva,toc.idtipo from cc_conceptos_otros_cargos coc, cc_tipo_otro_cargo toc where coc.idtipo = toc.idtipo and toc.idtipo = 1")
	 @oppago=[[]]
	 @oppago[0]="<Seleccion un concepto>","0"
	 count=1
	 for el in @formapago
	    @oppago[count]=el.cargo,el.idcargo
		count+=1
	 end
	 
  end
  
  def aplicagasto
  		@credito=params[:pago][:id]
		@cheque=params[:pago][:cheque]
		@ncheque=params[:pago][:ncheque]
	    
		@fechapago="#{params[:pago]["fecha(1i)"]}-#{params[:pago]["fecha(2i)"]}-#{params[:pago]["fecha(3i)"]}"
		@cantidad=quitacoma(params[:pago][:cantidad])
		@idconcepto=params[:pago][:concepto]
		if @idconcepto.to_i<=0 and  not float(@cantidad)
				session[:noticeg]="<font color=red>Seleccione un concepto y Verifique la cantidad..."
				
		else
				if @cantidad.to_f<=0
					session[:noticeg]="<font color=red>La cantidad debe ser mayor a <#{@cantidad}>..."
					
				else
					@sqlrecord="SELECT cc_ingresar_gasto_cobranza(#{@credito},#{@cheque},#{@idconcepto},#{@cantidad},'#{@fechapago}')"
					@guarda=VrCcCredito.find_by_sql(@sqlrecord)
					session[:noticeg]="<font color=blue>El gasto #{@guarda}fue aplicado satisfactoriamente"
					
				end
		end		
		redirect_to :action=>"cargagasto",:id=>"#{@cheque}-#{@credito}*#{@ncheque}"		
  end
  #---------------------------------------------------------------------------------------------------------------------------------------
  #modulo de cobranza grupal
  def cobgrupal
  		@parametro=params[:id]
		@datos=VrCcCredito.find_by_sql("SELECT * FROM v_cc_solgrupos WHERE vigente AND idsolgrupo=#{@parametro}")
		@sqlcre="select cliente,s.idcliente,c.monto as credito,ROUND(cc_calcular_monto_pagar(idcredito)) as monto_pagar,idcredito FROM "
		@sqlcre+="v_cc_solicitudes s, cc_creditos c where s.idsolicitud=c.idsolicitud and idsolgrupo = #{@parametro}"
		@datocli=VrCcCredito.find_by_sql(@sqlcre)
		@formapago=VrCcCredito.find_by_sql("select forma,idforma from cc_formas_pago order by 1")
	 	@oppago=[[]]
		@oppago[0]="<Seleccion una cuenta>","0"
	 	count=1
	 	for el in @formapago
	    	if el.idforma.to_i!=30
			  @oppago[count]=el.forma,el.idforma
			  count+=1	
			end
			
	 	end
		@dia=[]
		@mes=[]
		@anio=[]
		@anat=Time.now.year
		@anat=@anat.to_i-10
		for @i in (1..31)
			@anio[@i-1]=@anat
			@dia[@i-1]=@i
			if @i<=12
				@mes[@i-1]=@i
			end
			
			@anat=@anat+1
		end
		#elimina el hash para el inicio
		@cmpse="pgpo#{session[:id]}"
		session["#{@cmpse}"]={}
  end
  
  def cargagrupal
  	 @valor=params[:id]
	 if request.post?
	 	session[:noticeg]=""
	 end
	 @cheque=@valor[0,@valor.index("-")].to_s
	 @parametro=@valor[@valor.index("-")+1,(@valor.index("*")-(@valor.index("-")+1))].to_s
	 @ncheque=@valor[@valor.index("*")+1,@valor.length].to_s
	 #esto es para cargar los concepto menores a 14 capital y interes moratorio e interes normal
	 @sqldetpag="select cargo1::varchar(40),monto1,COALESCE((select monto from cc_condonaciones_sugeridas where	idconcepto=idconcepto1),0) as "
	 @sqldetpag+="condonar,idconcepto1,cns_pagare1,cns_otro_cargo1,pagado1,prioridad1 from 	cc_conceptos_condonar(#{@parametro}) as c where cns_pagare1=#{@cheque} and idcargo1<=14 order by"
	 @sqldetpag+=" cns_pagare1,prioridad1"
	 @detallepag=VrCcCredito.find_by_sql(@sqldetpag)
	 
	 #esto es para sacar el gasto de cobranza global
	 @sqlgcob="select 1 as cv,sum(monto1) as monto1,'GASTOS DE COBRANZA' as cargo1,"
	 @sqlgcob+=" (select idconcepto1 from 	cc_conceptos_condonar(#{@parametro}) as c where" 
 	 @sqlgcob+=" cns_pagare1=#{@cheque} and idcargo1>14 order by cns_pagare1,prioridad1 limit 1)"
  	 @sqlgcob+=" as idconcepto1 from cc_conceptos_condonar(#{@parametro}) where cns_pagare1=#{@cheque} and idcargo1>14  group by cv"
	 @detallecob=VrCcCredito.find_by_sql(@sqlgcob)
	 
	 # detalle de lo que esta pagado
	 @sqlpagado="select distinct cargo,idcargo,prioridad,cns_pagare,fecha,idconcepto,idcredito,capital,monto1 from ccr_obtiene_conceptos_pagados,"
	 @sqlpagado+="ccr_agrupa_pagado(#{@parametro},#{@cheque}) gru where idcredito=#{@parametro} and cns_pagare=#{@cheque} and gru.idcargo1=idcargo order by prioridad"
	 @detallepagado=VrCcCredito.find_by_sql(@sqlpagado)
	 
  
	 #@sqldetgasto="select fecha,cargo,monto,pagado from v_cc_otros_cargos_creditos where idtipo = 1 AND idcredito = #{@parametro} order by idtipo"
	 #@detgasto=VrCcCredito.find_by_sql(@sqldetgasto)
	 
	 @credito=VrCcCredito.find(@parametro)
	
	 
  end
  
  def aplicagrupo
  		#primero vamos a verificar si concide la cantidad con distribuida con la ficha
		@importe=params[:pago][:importe].to_f
		@referencia=params[:pago][:referencia]
		@tpago=params[:pago][:modo]
		@fecha=params[:pago]["fecha(3i)"]+"-"+params[:pago]["fecha(2i)"]+"-"+params[:pago]["fecha(1i)"]
		if @referencia.strip.empty? or @importe<=0 or @tpago.to_i==0
			@notice="<font color=red>Verifique los siguientes datos: Referencia no debe ser vacia,importe debe ser mayor a 0 y debe seleccionar el banco</font>"
		else
				@cmpse="pgpo#{session[:id]}"
				@hash=session["#{@cmpse}"]
				@sum=0.00
				for idcre in @hash
				   for pagare in @hash["#{idcre[0]}"]
						for concepto in @hash["#{idcre[0]}"]["#{pagare[0]}"]
							@sum+=@hash["#{idcre[0]}"]["#{pagare[0]}"]["#{concepto[0]}"].to_f
						end
				   end
				end
				#termina la validacion del hash
				@sum=@sum.to_s.to_f
				@importe=@importe.to_s.to_f
				if @importe==@sum
					#Guardar los datos
					#iniciando transaccion
					@tran=VrCcCredito.find_by_sql("begin")
					@pcont=""
					@sqlmovimiento="insert into cc_movimientos values (default,'#{@fecha}','-----',#{@sum.to_f},true,#{@tpago.to_i},'#{@referencia}')returning idmovimiento"
					@movimiento=VrCcCredito.find_by_sql(@sqlmovimiento)
					@idmov=@movimiento[0].idmovimiento.to_i
					for idcre in @hash
						for pagare in @hash["#{idcre[0]}"]
							@capital=0
							@normal=0
							@moratorio=0
							@cobranza=0
							for concepto in @hash["#{idcre[0]}"]["#{pagare[0]}"]
							    #verificar que concepto es 
								@sqlcon="select idcargo from cc_otros_cargos where idcredito = #{idcre[0]} "
								@sqlcon+="and cns_pagare = #{pagare[0]} and idconcepto=#{concepto[0]}"
								@cargos=VrCcCredito.find_by_sql(@sqlcon)
								if @cargos.length>0
									if @cargos[0].idcargo.to_i>14
										@cobranza=@hash["#{idcre[0]}"]["#{pagare[0]}"]["#{concepto[0]}"].to_f
										
									else
									    case @cargos[0].idcargo.to_i
											when 5 then
												 @moratorio=@hash["#{idcre[0]}"]["#{pagare[0]}"]["#{concepto[0]}"].to_f	
											when 6 then
												 @normal=@hash["#{idcre[0]}"]["#{pagare[0]}"]["#{concepto[0]}"].to_f
											
										end
									end
									
								else
									#no encontro ningu registro es capital
									@capital=@hash["#{idcre[0]}"]["#{pagare[0]}"]["#{concepto[0]}"].to_f
								end
								
								
							end
							#aqui va la ejecucion de la funcion de guardado ccr_registra_mov
							@execfuncion="select * from ccr_registrar_movgpo("
							@execfuncion+="#{idcre[0]},#{pagare[0]},true,#{@capital},#{@normal},"
							@execfuncion+="#{@moratorio},#{@cobranza},0,'#{@referencia}',#{@tpago},'#{@fecha}',#{@idmov})"
							#validar si borramos la distribucion en el pagare
							if @capital>0 or @normal>0 or @moratorio>0 or @cobranza>0
								@resul=VrCcCredito.find_by_sql(@execfuncion)
							
							end
							
						end
					end
					#genera la poliza
					@sqlm="select cc_contabilizar_movimiento(#{@idmov})"
					@resul=VrCcCredito.find_by_sql(@sqlm)
					#guardando transaccion
					@tran=VrCcCredito.find_by_sql("commit")
					session["#{@cmpse}"]={}
					@notice="<h3><font color=blue>La Cobranza fue realizada Satisfactoriamente...</h3></font>"
				else
					@notice="<font color=red>La cantidad distribuida no coincide con el importe de la ficha... verifique#{@importe}==[#{@sum}]</font>"
				end
				
		end
	render :text=>@notice
  end
 #metodo para cargar los cheque de los cliente en el pago grupal
  def cargachcli
  		@parametro=params[:id][0,params[:id].index("-")]
		@nombre=params[:id][params[:id].index("-")+1,params[:id].length]
  		@sqlpag="SELECT * from (select fecha_pagar,idcredito,dias_vencido,cns_pagare,pagado from v_cc_pagares	where idcredito = #{@parametro} order by fecha_pagar) as cTmp"
		@datopagare=VrCcCredito.find_by_sql(@sqlpag)
  end
  
def distribuye
  	
 @parametro=params[:id]
 @ficha=params[:pagodistri].to_f
 @fecha=params[:fecha]
 @anio=@fecha[0,@fecha.index("-")]
 @rfecha=@fecha[@fecha.index("-")+1,@fecha.length]
 @mes=@rfecha[0,@rfecha.index("-")]
 @dia=@rfecha[@rfecha.index("-")+1,@rfecha.length]
 if Date::valid_civil?(@anio.to_i, @mes.to_i, @dia.to_i)!=nil
	@valficha=params[:pagodistri].to_f
	if @valficha<=0
			render :text=> "No se puede distribuir la cantidad porque es menor o igual a 0"
	end

	@sqlcre="select cliente,s.idcliente,c.monto as credito,ROUND(cc_calcular_monto_pagar(idcredito)) as monto_pagar,idcredito FROM "
	@sqlcre+="v_cc_solicitudes s, cc_creditos c where s.idsolicitud=c.idsolicitud and idsolgrupo = #{@parametro}"
	@datocli=VrCcCredito.find_by_sql(@sqlcre)
	@cmpse="pgpo#{session[:id]}"
	session["#{@cmpse}"]={}
	
	
	#meter aqui el while para distribuir todo el monto
	@control=0
	@suma=0.00
	while @ficha.to_f>0 and @control<=24
	  @control+=1
	  for cli in @datocli
		@sqlupdatepag="select * from cc_calcular_dias_vencidos_pagares(#{cli.idcliente},'#{@fecha}')"
		@updte=VrCcCredito.find_by_sql(@sqlupdatepag)
		@sqlpag="SELECT * from (select fecha_pagar,dias_vencido,cns_pagare,pagado from v_cc_pagares	where "
		@sqlpag+="idcredito = #{cli.idcredito} order by fecha_pagar) as cTmp"
		@datopagare=VrCcCredito.find_by_sql(@sqlpag)	
		@count=0
		for pag in @datopagare
		  begin		
			if session["#{@cmpse}"]["#{cli.idcredito}"].has_key?("#{pag.cns_pagare}")
					@validahash=true
			else
					@validahash=false
			end
		  rescue Exception => err
			@validahash=false
		  ensure
		  end
		  if @count==0 and @validahash!=true
		    if session["#{@cmpse}"].has_key?("#{cli.idcredito}")!=true
		  		session["#{@cmpse}"]["#{cli.idcredito}"]={}
			end
			@sqldetpag="select cargo1::varchar(40),idcargo1,monto1,idcargo1,COALESCE((select monto from cc_condonaciones_sugeridas"
			@sqldetpag+=" where	idconcepto=idconcepto1),0) as condonar,idconcepto1,cns_pagare1,"
			@sqldetpag+="cns_otro_cargo1,pagado1,prioridad1 from cc_conceptos_condonar(#{cli.idcredito}) as c where "
			@sqldetpag+="cns_pagare1=#{pag.cns_pagare} order by cns_pagare1,prioridad1"
	 		@detallepag=VrCcCredito.find_by_sql(@sqldetpag)
			session["#{@cmpse}"]["#{cli.idcredito}"]["#{pag.cns_pagare}"]={}
			for det in @detallepag
				 if det.idcargo1.to_i==6 or det.idcargo1.to_i== -1
		  		 	if errfloat(@ficha.to_f)>0
						if @ficha.to_f>= det.monto1.to_f
						   @ficha-=det.monto1.to_f
						   @monto=det.monto1.to_f
						else
						   @monto=@ficha
						   @ficha-=@ficha 		
						end
						session["#{@cmpse}"]["#{cli.idcredito}"]["#{pag.cns_pagare}"]["#{det.idconcepto1}"]="#{@monto}"
						@suma+=@monto.to_f
		  		 		#ver si ya entro al a un pagare entrar hasta el proximo
						@count=1
					end
				 end
			  end
			
		   end
		 end
	   end
	end
  	if @valficha>0
			render :text=>"<script languaje=javascript>var upd=document.getElementById('suco');upd.value="+@suma.to_f.to_s+"</script><font color=blue>La cantidad de #{number_to_currency(@valficha)} fue distribuida y sobro #{number_to_currency(@ficha)} <br>#{@texto}</font>"		
	end
#termina la validacion  de la fecha	
else 
	render :text=>"<font color=red>La Fecha es incorrecta, verifique</fornt>"
end

end
  def guardacant
  		@idcredito=params[:id]
		@cheque=params[:pago][:cheque]
		@cmpse="pgpo#{session[:id]}"
	    @hash=session["#{@cmpse}"]
		@tamano=params[:concepto].length
		@arrconcepto=Array(params[:concepto])
		@i=0
		@texto=""
		while @i<@tamano 
			el=Array(@arrconcepto[@i])
			if @hash.has_key?("#{@idcredito}")
			    if @hash["#{@idcredito}"].has_key?("#{@cheque}")
					@hash["#{@idcredito}"]["#{@cheque}"]["#{el[0]}"]="#{el[1]}"
					
				else
					@hash["#{@idcredito}"]["#{@cheque}"]={}
					@hash["#{@idcredito}"]["#{@cheque}"]["#{el[0]}"]="#{el[1]}"
				end
			else
			   @hash["#{@idcredito}"]={}
			   @hash["#{@idcredito}"]["#{@cheque}"]={}
			   @hash["#{@idcredito}"]["#{@cheque}"]["#{el[0]}"]="#{el[1]}"
			end
			@i+=1
		end
		
		#checa la sumatoria del hash
		@cmpse="pgpo#{session[:id]}"
		@hash=session["#{@cmpse}"]
		@sum=0.00
		for idcre in @hash
				for pagare in @hash["#{idcre[0]}"]
					for concepto in @hash["#{idcre[0]}"]["#{pagare[0]}"]
						@sum+=@hash["#{idcre[0]}"]["#{pagare[0]}"]["#{concepto[0]}"].to_f
					end
				end
		end
  		#termina la sumatoria del hash
		render :text=>"<script languaje=javascript>var upd=document.getElementById('suco');upd.value="+@sum.to_s+"</script><font color=blue>#{@texto} Guardado satisfactoriamente...</font>"
		
  end
  
  
end
