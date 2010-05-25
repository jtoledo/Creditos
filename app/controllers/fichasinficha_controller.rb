class FichasinfichaController < ApplicationController
 
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
  def generacion_ficha
	@idcredito=params[:id]
	#Carga fecha actual
	@seldia=Time.now.day
	@selmes=Time.now.month
	@selanio=Time.now.year
	@fecha=@selanio.to_s+"-"+@selmes.to_s+"-"+@seldia.to_s
	
	@datos=VrCcCredito.find(@idcredito)
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
	@sqlcre="SELECT folio,f_ministracion,monto,cc_calcular_monto_actual(idcredito) as montoActual,fecha_hasta,promotor,idcredito,idsolicitud,grupo,"
	@sqlcre+="fecha_vencimiento,cliente,f_aprobacion FROM v_cc_creditos c WHERE idcliente=#{@datos.idcliente} and idcredito=#{@idcredito} and entregado_boo"
	@datocre=VrCcCredito.find_by_sql(@sqlcre)
	@sqlpag="select fecha_pagar,idcredito,dias_vencido,cns_pagare,pagado,"
	@sqlpag+="(select count(*)::int from v_cc_fichas where idcredito=#{@idcredito} and cns_pagare=vp.cns_pagare) as no_fichas from v_cc_pagares vp where idcredito = #{@idcredito} order by fecha_pagar"
	@datopagare=VrCcCredito.find_by_sql(@sqlpag)
	  
	  #opciones de pago
# 	  @formapago=VrCcCredito.find_by_sql("select forma,idforma from cc_formas_pago order by 1")
# 	  @oppago=[[]]
# 	  @oppago[0]="<Seleccion una cuenta>","0"
# 	  count=1
# 	  for el in @formapago
# 		@oppago[count]=el.forma,el.idforma
# 		count+=1
# 	  end
	  #inicializar el hash para almacenar
	  @cmpse="pind#{session[:id]}"
	  session["#{@cmpse}"]={}
  end
  
  def datos_ficha
	@parametros=params[:id]	
	
	if request.post?
	  session[:notice]=""
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
	 
	@datosCredito=@parametros.split('-')
# 	@idcredito=@datosCredito[1]
# 	puts "datos_ficha:"
# 	i=1
# 	@datosCredito.each {|index|
# 	  puts "#{i}: #{index}"
# 	  i+=1;
# 	}
# 	puts @datosCredito[0]
# 	puts @datosCredito[1]
# 	puts @datosCredito[2]
# 	puts @datosCredito[3]
# 	@nombre=@datosCredito[3]
# 	puts @nombre
	@formapago=VrCcCredito.find_by_sql("select forma,idforma from cc_formas_pago order by 1")
	@oppago=[[]]
	@oppago[0]="<Seleccion una cuenta>","0"
	count=1
	for el in @formapago
	  @oppago[count]=el.forma,el.idforma
	      count+=1
	end
  end
  
  def reporte_fichasinficha
#       @cmpse="pind#{session[:id]}"
#       @hash=session["#{@cmpse}"]
#       puts @hash
#       puts session[:cuenta]
    @parametros=params[:id]      
    @datosCredito=@parametros.split('-')
    @ficha=params[:pago][:ficha].to_f
    @monto_letra=numlet(@ficha)
    @referencia=params[:pago][:referencia]
    @idformapago=params[:pago][:modo]
    @fecha=params[:pago]["fecha(3i)"]+"-"+params[:pago]["fecha(2i)"].rjust(2,'0')+"-"+params[:pago]["fecha(1i)"].rjust(2,'0')
    @notice=''
    @idcredito=@datosCredito[1]
    @cliente=@datosCredito[3]
    @asesor=@datosCredito[4]
#     puts "ficha: #{@ficha}, referencia #{@referencia}, idformapago: #{@idformapago}, fecha: #{@fecha}"
    if @referencia.strip.empty? or @ficha<=0 or @idformapago.to_i==0
      @notice="<font color=red>Verifique los siguientes datos: Referencia no debe ser vacia,importe debe ser mayor a 0 y debe seleccionar el banco</font>"
#       @notice="<script language='javascript'>alert('Verifique los siguientes datos: Referencia no debe ser vacia,importe debe ser mayor a 0 y debe seleccionar el banco')</script>"
#       @notice="<script language='javascript'>alert(this.ref)</script>"
#       puts "ERROR"
      #render :text=>@notice
      
    else
      @formapago=VrCcCredito.find_by_sql("select forma from cc_formas_pago where idforma=#{@idformapago} limit 1")
#       for el in @formapago
# 	@modoPago[0]=el.forma
#       end
      @modo=@formapago[0].forma.upcase      
      @ssql="select folio from v_cc_creditos where idcredito=#{@datosCredito[1]}"
      @datos=VrCcCredito.find_by_sql(@ssql)
      @folioCredito=@datos[0].folio
      @ssql="select cc_nuevo_fff(#{@datosCredito[1]},#{@datosCredito[0]},#{@ficha},'#{@fecha}',#{@idformapago},'#{@referencia}') as no"
      @datos=VrCcCredito.find_by_sql(@ssql)
      @folio=[]
      for el in @datos
	@folio[0]=el.no
      end
      @folio_fsf=@folio[0]
#       puts "modoPago: #{@modo}, folio: #{@folio_fsf}"
    end
    
#     render :text=>@notice
  end
  
  def reimpresion
      @parametros=params[:id]      
      @datosCredito=@parametros.split('-')
      @fichas=VrCcCredito.find_by_sql("select * from v_cc_fichas where idcredito=#{@datosCredito[1]} and cns_pagare=#{@datosCredito[0]}")
  end
  
  def reimp_fichasinficha
      @idFicha=params[:id]      
      @notice=''
      @datosCredito=[]
      @sqlficha="select f.id,f.folio,f.monto,f.fecha,f.forma,f.cliente,f.promotor "
      @sqlficha+="from v_cc_fichas f inner join cc_creditos c using (idcredito) where f.id="+@idFicha
      @ficha=VrCcCredito.find_by_sql(@sqlficha)
#       puts "************************************************************************"
      @ficha.each do |r| 
# 	 puts r.id
# 	 puts r.folio
# 	 puts r.cliente
# 	 puts r.promotor
# 	 puts r.fecha
# 	 puts r.monto
# 	 puts r.forma
	@folioCredito=r.folio
	@folio_fsf=r.id.to_s.rjust(7,'0')
	@cliente=r.cliente
	@asesor=r.promotor
	@fecha=r.fecha
	@ficha=r.monto
	@monto_letra=numlet(@ficha)
	@modo=r.forma
      end
      
     
      
#       puts "***************************************"
#       puts @datosCredito[0]
#       puts @datosCredito[1]
#       puts @datosCredito[2]
#       puts @datosCredito[3]
  end
end
