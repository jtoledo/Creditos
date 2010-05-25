class SolicitudesController < ApplicationController
  before_filter :autorizo,:except=> :index
  include ActionView::Helpers::NumberHelper
  include AjaxScaffold::Controller
  
  after_filter :clear_flashes
  before_filter :update_params_filter
  
  def update_params_filter
    update_params :default_scaffold_id => "vr_cc_solicitudes", :default_sort => nil, :default_sort_direction => "asc"
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
#     @estatus_seleccionado="a"
#     puts "----------------------------------------- --------------------------------------------"
    if params[:id]!=nil
      @parametros=params[:id]
#       puts "---------------------------------------------------------------------------------> LIST"
      r=@parametros.split('*&*')    
#       puts r[0]
#       puts r[1] 
#       puts r[2]
    end
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
    @promotores=VrCcPromotore.find(:all,:order=>'promotor')
    #@promotores=Dictionary.new
    #nompro=""
    #for promotor in @promotor
      #nompro=promotor.nombre + " " + promotor.ap_paterno + " " + promotor.ap_materno
# 	    @promotores[cont]=nompro,promotor.id
    #@promotores[nompro]=promotor.id
# 	    cont+=1
    #end
    #@promotores.order_by_key
    
# 	  @estatus_seleccionado=""
# 	  puts "************************************"
# 	  puts @params[:estatus_seleccionado]
# 	  puts "************************************"
    @estatus=VrCcEstsolicitude.find(:all,:order=>'id')
    @idestatus=2 #AGENDADAS
    @idpromotor=-1 #TODOS LOS PROMOTORES
    @cliente='' #TODOS LOS CLIENTES
   
#     puts "estatus -------------------------------------------------------------------"
#     puts @estatus
    #@idestatus=5
    #@estatu="<<TODOS>>","-1"
# 	  @estatus=[[]]
# 	  @estatus={}
    #@estatus=Dictionary.new
#     cont=0
# 	  @estatus[cont]="<<TODOS>>","-1"
    #@estatus["<<TODOS>>"]="-1"
#     cont=1
    #for estatu in @estatu
      #@estatus[cont]=estatu.estatus,estatu.id
    # @estatus[estatu.estatus]=estatu.id
# 	    cont+=1
    #end
#     puts "######################################################################################"
    #puts @estatus
    #@estatus.each {|k,v| puts "#{k}=>#{v}"}          
    #render :action => "component", :layout => false
      
    #if request.xhr?
    #else      
# 	  @estatus.each {|k,v| puts "#{k}=>#{v}"}
    session["#{session[:id]}"]=""
    if params[:id]!=nil
#       puts "************************ PARAMS ID ******************************************"	
#       puts params[:id]
      @parametros=params[:id]
      @datosFiltro=@parametros.split('*&*') 
    end
# 	  if request.post?
    if params[:cliente_buscar]!=nil
      #si es el filtrado nombre
#       puts "************************ CLIENTE VIA 1 ******************************************"
#       puts params[:cliente_buscar]
      @cliente=params[:cliente_buscar]
      session["#{session[:id]}"]="where acreditado like '%"+@cliente.upcase+"%'"
    else
      if params[:id]!=nil
# 	puts "************************ CLIENTE VIA 2 ******************************************"
	if @datosFiltro[3]!=nil
	  @cliente=@datosFiltro[3]
	  if @cliente!=''
	    session["#{session[:id]}"]="where acreditado like '%"+@cliente.upcase+"%'"
	  end
	end 
      end
    end
    
    if params[:estatus_seleccionado]!=nil
      #if session["#{session[:id]}"]==""
#       puts "************************ ID ESTATUS VIA 1 ******************************************"
      #puts params[:estatus_seleccionado]
      if params[:estatus_seleccionado].to_i>0
	@idestatus=params[:estatus_seleccionado]	
	if session["#{session[:id]}"]==""
	  session["#{session[:id]}"]="where idestatus="+params[:estatus_seleccionado].to_s
	else
	  session["#{session[:id]}"]+=" and idestatus="+params[:estatus_seleccionado].to_s
	end
      else
	@idestatus='-1'
      end 
#       puts @idestatus
    else
      if params[:id]!=nil
# 	puts "************************ ID ESTATUS VIA 2 ******************************************"	
	if @datosFiltro[1].to_i>0
	  @idestaus=@datosFiltro[1]
	  if session["#{session[:id]}"]==""
	    session["#{session[:id]}"]="where idestatus="+@datosFiltro[1].to_s
	  else
	    session["#{session[:id]}"]+=" and idestatus="+@datosFiltro[1].to_s
	  end
	else
	  @idestaus='-1'
	end
# 	puts @datosFiltro[1]
      end
    end
    #puts @idestatus
    #defined?(params[:promotor_seleccionado])!=nil
    if params[:promotor_seleccionado]!=nil
#       puts "************************ ID PROMOTOR VIA 1******************************************"
#       puts params[:promotor_seleccionado]
      if params[:promotor_seleccionado].to_i>0
	@idpromotor=params[:promotor_seleccionado]
	if session["#{session[:id]}"]==""
	  session["#{session[:id]}"]="where idpromotor="+params[:promotor_seleccionado].to_s
	else
	  session["#{session[:id]}"]+=" and idpromotor="+params[:promotor_seleccionado].to_s
	end
      else
	@idpromotor='-1'
      end
    else
      if params[:id]!=nil
# 	puts "************************ ID PROMOTOR VIA 2 ******************************************"
# 	puts @datosFiltro[2]
	if @datosFiltro[2].to_i>0
	  @idpromotor=@datosFiltro[2]
	  if session["#{session[:id]}"]==""
	    session["#{session[:id]}"]="where idpromotor="+@datosFiltro[2].to_s
	  else
	    session["#{session[:id]}"]+=" and idpromotor="+@datosFiltro[2].to_s
	  end
	else
	  @idpromotor='-1'
	end
      end
    end
  # 	  else
  # 	    session["#{session[:id]}"]=""
  # 	  end 
    #end
      #desde componet
      #desde cargar_datos
#     puts "============================================================================================================================"
#     puts "idestaus=#{@idestatus}"
#     puts "idpromotor=#{@idpromotor}"
#     puts "cliente=#{@cliente}"
#     puts "---"
#     puts "idestaus :estatus_seleccionado=#{params[:estatus_seleccionado]}"
#     puts "---"
#     puts "where=>#{session["#{session[:id]}"]}"
    @filtro=session["#{session[:id]}"]
    if @filtro==""
      @filtro=" where idestatus=2"
      @idestatus='2'
    end
    @show_wrapper = true if @show_wrapper.nil?
    @sort_sql = VrCcSolicitudes.scaffold_columns_hash[current_sort(params)].sort_sql rescue nil
    @sort_by = @sort_sql.nil? ? "#{VrCcSolicitudes.table_name}.#{VrCcSolicitudes.primary_key} asc" : @sort_sql  + " " + current_sort_direction(params)
    @paginator, @vr_cc_solicitudes = paginate(:vr_cc_solicitudes, :order => @sort_by,:joins=>"#{@filtro}", :per_page => default_per_page)
    #default_per_page

    render :action => "component", :layout => false
  end

  def new
    @vr_cc_solicitudes = VrCcSolicitudes.new
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
      @vr_cc_solicitudes = VrCcSolicitudes.new(params[:vr_cc_solicitudes])
      @successful = @vr_cc_solicitudes.save
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
      @vr_cc_solicitudes = VrCcSolicitudes.find(params[:id])
      @successful = !@vr_cc_solicitudes.nil?
    rescue
      flash[:error], @successful  = $!.to_s, false
    end
    
    return render(:action => 'edit.rjs') if request.xhr?
    if @successful
      @options = { :scaffold_id => params[:scaffold_id], :action => "update", :id => params[:id] }
      render :partial => 'tags', :layout => true
    else
      return_to_main
    end    
  end

  def update
    begin
      @vr_cc_solicitudes = VrCcSolicitudes.find(params[:id])
      @successful = @vr_cc_solicitudes.update_attributes(params[:vr_cc_solicitudes])
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
      @successful = VrCcSolicitudes.find(params[:id]).destroy
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
  
  def cargadatos
    @parametros=params[:id]
#     puts "-------------------------------------> CARGAR DATOS"
#     puts params[:id]
    @datosFiltro=@parametros.split('*&*')
    @solicitud=VrCcPrincipale.find(@datosFiltro[0])
    @monto=quitacoma(@solicitud.monto)
    #redirect_to :action => 'list'
  end
  
  def cargaproducto
    #no funcia
    @product=params[:cliente][:CodigoRut]
    #@=Cliente.find_by_sql("select max(codigocli)+1 as Fol from clientes where CodigoRut=#{@ruta}")
    render(:update) do |page|
      page["vr_cc_solicitudes[intnormal]"].value=20
    end    
  end
  
  def aceptacredito
    @parametros=params[:id]    
    @idsolicitud=params[:vr_cc_solicitudes][:idsolicitud]
    @idproducto=params[:vr_cc_solicitudes][:idproducto]
    @porcentaje=params[:vr_cc_solicitudes][:porcentaje]
    @intnormal=params[:vr_cc_solicitudes][:intnormal]
    @intmoratorio=params[:vr_cc_solicitudes][:intmora]
    @montoautoriza=quitacoma(params[:vr_cc_solicitudes][:montoautoriza].strip)
    @fministracion="#{params[:vr_cc_solicitudes]['fministracion(3i)']}-#{params[:vr_cc_solicitudes]['fministracion(2i)']}-#{params[:vr_cc_solicitudes]['fministracion(1i)']}"
    @fprimerpago="#{params[:vr_cc_solicitudes]['fprimerpago(3i)']}-#{params[:vr_cc_solicitudes]['fprimerpago(2i)']}-#{params[:vr_cc_solicitudes]['fprimerpago(1i)']}"
    @diasdgracia=params[:vr_cc_solicitudes][:diasdgracia]
    @fcomite="#{params[:vr_cc_solicitudes]['fcomite(3i)']}-#{params[:vr_cc_solicitudes]['fcomite(2i)']}-#{params[:vr_cc_solicitudes]['fcomite(1i)']}"
    @garliquida=quitacoma(params[:vr_cc_solicitudes][:garliquida].strip)
    @meses=params[:vr_cc_solicitudes][:meses]
    #hacer las validadciones de fechas 2 o 17
    @dfministra=params[:vr_cc_solicitudes]["fministracion(3i)"].to_i
    @dfppago=params[:vr_cc_solicitudes]["fprimerpago(3i)"].to_i
    if (@dfministra!=2 and @dfministra!=17) 
      flash[:notice]="Los dias de Ministracion deben ser 2 o 17 verifique"
      redirect_to(:back)
      #redirect_to :action=>"cargadatos",:id=>params[:vr_cc_solicitudes][:idsolicitud]
    else
      if (@dfppago!=2 and @dfppago!=17)
	flash[:notice]="Los dias de pago debe ser 2 o 17 verifique"
	redirect_to(:back)
      else
	if (@diasdgracia.to_i<=0)
	  flash[:notice]="El dia de gracia debe ser mayor a 0"
	  redirect_to(:back)
	else 
	  #validar si los datos son numericos
	  begin
	    b=@diasdgracia.to_i.integer?
	    b=@montoautoriza.to_i.integer?
	    @error=0
	  rescue Exception => err
	    @error=1
	  ensure
	  end	
	  if @error==1
	    flash[:notice]="Dia de gracia y Monto autorizado deben ser numericos verifique y tenga cuidado..."
	    redirect_to(:back)
	  else
	    begin
	      @tran=VrCcPrincipale.find_by_sql("begin")
	      @sql=VrCcPrincipale.find_by_sql("update cc_solicitudes set idestatus = 3 where idsolicitud=#{@idsolicitud}")
	      @execsql="insert into cc_creditos(idsolicitud,monto,folio,dias_gracia,f_aprobacion,idproducto,interes_normal,interes_moratorio,gtia_liquida"
	      @execsql+=",f_ministracion,meses,interes_mensual,f_comite)"
	      @execsql+=" 	values(#{@idsolicitud},#{@montoautoriza},'',#{@diasdgracia},'#{Date.today.day}-#{Date.today.month}-#{Date.today.year}',#{@idproducto},#{@intnormal},"
	      @execsql+="#{@intmoratorio},#{@porcentaje},'#{@fministracion}',#{@meses},'f','#{@fcomite}') returning folio,idcredito"
	      @sql=VrCcPrincipale.find_by_sql(@execsql)

	      @execsql1="SELECT * FROM cc_generar_pagares(#{@sql[0].idcredito},'#{@fprimerpago}','#{@fministracion}')"
	      @sql2=VrCcPrincipale.find_by_sql(@execsql1)
	      @tran=VrCcPrincipale.find_by_sql("commit")
	    rescue Exception => err
	      flash[:notice]="Existen campos incorrectos"
	      @tran=VrCcPrincipale.find_by_sql("rollback")
	    ensure
	    end
	    redirect_to :action=>"list",:id=>@parametros
	  end
	end
      end
    end	 
  end
 
end
