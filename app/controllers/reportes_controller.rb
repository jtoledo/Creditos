class ReportesController < ApplicationController
  include AjaxScaffold::Controller
  
  after_filter :clear_flashes
  before_filter :update_params_filter
  
  def update_params_filter
    update_params :default_scaffold_id => "vr_cc_credito", :default_sort => nil, :default_sort_direction => "asc"
  end
  
  def index
    redirect_to :action => 'list'
  end
 
  def list
  end
  
  def component  
    @show_wrapper = true if @show_wrapper.nil?
	#obtener datos de la tabla productos
	@producto=VrCcCredito.find_by_sql("select idproducto,producto from cc_productos")
	@vproduct=[[]]
	@vproduct[0]="Seleccione un elemento","0"
	@count=1
	for el in @producto
		@vproduct[@count]=el.producto,el.idproducto
		@count+=1
	end
  end
  
  def reportecredito
  		@creditonoent=params[:reporte][:icre]
		@idproducto=params[:reporte][:producto]
		@ordenar=params[:reporte][:ordena]
		@tiporeporte=params[:reporte][:tiprep]
		if @tiporeporte.to_i==1
				@sqlrep="select c.folio,s.cliente,c.monto,c.gtia_liquida,producto,folio_solicitud,f_comite,f_entrega from " 
				@sqlrep+="v_cc_creditos c,v_cc_solicitudes s where c.idsolicitud=s.idsolicitud"
				if @creditonoent.to_i==0
					@sqlrep+=" and f_entrega is not null" 
				end
				
				
				if @idproducto.to_i>0
					@sqlrep+=" and idproducto = #{@idproducto}"
				end
				#verificar si es concheque quitar el ordenamiento
				if @ordenar=="nombre_banco,producto,cliente" or @ordenar=="nombre_banco,ref_cheque" or @ordenar=="num_cuenta,cliente"
					@ordenar=""
				else
					@sqlrep+=" order by #{@ordenar}"	
				end
				@datos=VrCcCredito.find_by_sql(@sqlrep)
		end
		if @tiporeporte.to_i==2
		
				@sqlrepc="select vc.folio,s.cliente,vc.monto,vc.gtia_liquida,producto,folio_solicitud,ref_cheque,nombre_banco,num_cuenta,f_comite,f_entrega,"
				@sqlrepc+="vc.producto from v_cc_creditos vc,v_cc_solicitudes s, cc_cheques_ministracion cm,cheques c,cuentas_bancarias cb, bancos b  where " 
				@sqlrepc+="vc.idsolicitud=s.idsolicitud	and vc.idcredito=cm.idcredito and c.idmov=cm.idmov and c.idcuenta=cb.idcuenta and not ch_cancelado and "
				@sqlrepc+="cb.idbanco=b.idbanco"
				if @creditonoent.to_i==0
					@sqlrepc+=" and f_entrega is not null" 
				end 
				if @idproducto.to_i>0
					@sqlrepc+=" and idproducto = #{@idproducto}"
				end
				@sqlrepc+=" order by #{@ordenar}"
				@datos=VrCcCredito.find_by_sql(@sqlrepc)
		end
  end
  
  def filtros_cobranza
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
    
    sql="select idproducto as id,producto from v_cc_productos union (select -1,' <<TODOS>>') order by 1;"
    @productos=VrCcCredito.find_by_sql(sql)        
    sql="select idforma as id,forma from cc_formas_pago union (select -1,' <<TODOS>>') order by 1;"
    @formas=VrCcCredito.find_by_sql(sql)    
  end
  
  def gtias_liquidas
     sql="select folio,c.monto as monto_credito,grupo,cliente,dgl.monto,referencia,gl.fecha,gtia_liquida,forma,c.idcredito,"
     sql+="dgl.iddepgtia,cns,c.idcliente,gl.idformapago from cc_dep_gtias_liquidas gl inner join cc_detalles_gtias_liquidas dgl "
     sql+="using(iddepgtia) inner join v_cc_creditos c using(idcredito) inner join cc_formas_pago fp on gl.idformapago=fp.idforma;"
     @gtias=VrCcCredito.find_by_sql(sql)     
  end
  
  def dep_sinficha
     sql="select folio,cns_pagare,monto,referencia,fecha,forma,cliente,promotor,idcredito,"
     sql+="to_char((select no from (select row_number() over (order by cns_pagare) as no,cns_pagare from cc_pagares where "
     sql+="idcredito=f.idcredito) as tmp where tmp.cns_pagare=f.cns_pagare),'FM00') as no_pagare,"
     sql+="(select grupo from v_cc_creditos where idcredito=f.idcredito) as grupo from v_cc_fichas f;"
     @depsinficha=VrCcCredito.find_by_sql(sql)     
  end
     
  def rep_cobranza    
    idProd=params[:producto]
    idFormaPago=params[:formapago]
    @repSimplificado=params[:simplificado]        
#     puts "************************************* "+params[:fechas][:usar]
    @producto=""
    @formaPago=""
     if idProd.to_i!=-1      
      sql="select producto from cc_productos where idproducto=#{idProd};"
      @descProd=VrCcCredito.find_by_sql(sql)
      @producto=@descProd[0].producto
    end 
    
    if idFormaPago.to_i!=-1
      sql="select forma from cc_formas_pago where idforma=#{idFormaPago};"
      @descFormaPago=VrCcCredito.find_by_sql(sql)
      @formaPago=@descFormaPago[0].forma
    end
    
    if params[:fechas][:usar]=="1"
      fInicial=params[:inicio][:year].rjust(2,'0')+"-"+params[:inicio][:month].rjust(2,'0')+"-"+params[:inicio][:day]
      fFinal=params[:fin][:year].rjust(2,'0')+"-"+params[:fin][:month].rjust(2,'0')+"-"+params[:fin][:day]	
      @title=":: DEPOSITOS HECHOS DEL DIA #{fInicial} AL #{fFinal}"
      if @producto!=""
	@title+=" - #{@producto}"
	if @formaPago!=""
	  @title+=" [#{@formaPago}] ::"
	else
	  @title+=" ::"
	end
      else
	if @formaPago!=""
	  @title+=" [#{@formaPago}] ::"
	else
	  @title+=" ::"
	end
      end
    else
      fInicial=params[:captura][:year].rjust(2,'0')+"-"+params[:captura][:month].rjust(2,'0')+"-"+params[:captura][:day]
      fFinal=params[:captura][:year].rjust(2,'0')+"-"+params[:captura][:month].rjust(2,'0')+"-"+params[:captura][:day]
      @title=":: RELACIÓN DE CAPTURA DEL DIA #{fInicial}"
      if @producto!=""
	@title+=" - #{@producto} ::"
      else
	@title+=" ::"
      end
    end          
    
    sql="select fecha_movimiento1 as fecha_movimiento,cliente1::varchar(50) as cliente,grupo1::varchar(30) as grupo,"
    sql+="referencia1::varchar(30) as referencia,credito1 as credito, monto1 as monto,capital1 as capital,int_normal1 as int_normal,"
    sql+="int_moratorio1 as int_moratorio,gtos_cobranza as gtos_cobranza,forma_pago::varchar(30),"
    sql+="normal_condonacion::varchar(20) as tipo_movimiento,fecha_registro1 as fecha_captura,idcredito1 from "
    sql+="cc_reporte_cobranza2('#{fInicial}','#{fFinal}',#{idProd},#{idFormaPago},#{params[:fechas][:usar]})"
#      puts "-------------------------------------------- CONSULTA ---------------------------------------------------------------------------"
#      puts sql
#      puts "---------------------------------------------------------------------------------------------------------------------------------"
    @cobranza=VrCcCredito.find_by_sql(sql)
  end
end
