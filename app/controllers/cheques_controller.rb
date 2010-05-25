class ChequesController < ApplicationController

  def montolet
    @num=params[:cheque][:monto]
    @ltra=numlet(@num.to_s)
    render(:update) do |page|
      page["cheque[montoletra]"].value="mil quinientos #{@ltra}"
      
      
      
    end
  end
  def index
  		@parametro=params[:id][:id]
	 	@solicitud=params[:id][:solicitud]
		@datos=VrCcCredito.find(@parametro)
		
		@sql="select (nombre_banco||' '||num_cuenta)::varchar(50) as cuenta,(case when cheque then 'Cheque' else 'Trans.' end)::varchar(6) as tipo,"
		@sql+="ref_cheque,fecha,monto,concepto_min::varchar(20),cheque,formato,ch_m.idcredito,ch.idmov,ch.id_ejercicio,ch.cns_mes,ch.cns_asiento,"
		@sql+="nombre_banco,num_cuenta from cc_conceptos_ministracion co_m,cc_cheques_ministracion ch_m,"
		@sql+="cheques ch,cuentas_bancarias cb,bancos b where ch_m.idcredito=#{@parametro} and ch_m.idc_min=co_m.idc_min and ch_m.idmov=ch.idmov"
		@sql+=" and ch.idcuenta=cb.idcuenta and cb.idbanco=b.idbanco"
		@conteo=VrCcCredito.count_by_sql(@sql)
		@datocheque=VrCcCredito.find_by_sql(@sql)
		if @conteo>0
			@sql1="select sum(monto) as monto from cc_conceptos_ministracion co_m,cc_cheques_ministracion ch_m,"
			@sql1+="cheques ch,cuentas_bancarias cb,bancos b where ch_m.idcredito=#{@parametro} and ch_m.idc_min=co_m.idc_min and ch_m.idmov=ch.idmov"
			@sql1+=" and ch.idcuenta=cb.idcuenta and cb.idbanco=b.idbanco"
			@dat=VrCcCredito.find_by_sql(@sql1)
			@entregado=@dat[0].monto
		else
			@entregado=0
		end
  end
  def insertacheque
  		@parametro=params[:id][:id]
	 	@solicitud=params[:id][:solicitud]
		
		@pol=""
		#guardar cheque
		if request.post? and defined?(params[:cheque][:dsp])!=nil
				@monto=quitacoma(params[:cheque][:monto])
				@ncheque=params[:cheque][:ncheque]
				@disponible=quitacoma(params[:cheque][:dsp])
				@idc_min=params[:cheque][:concepto]
				@cuenta=params[:cheque][:cuenta]
				@fecha="#{params[:cheque]['fecha(3i)']}-#{params[:cheque]['fecha(2i)']}-#{params[:cheque]['fecha(1i)']}"
				begin
					b=@monto.to_i.integer?
					b=@ncheque.to_i.integer?
					@error=0
				rescue Exception => err
					@error=1
				ensure
					
				end	
				if @error==1
					flash[:notice]="Verifique el monto y la referencia/numero de cheque sean correctos..."
					
				else
					if @monto.to_f>@disponible.to_f
						flash[:notice]="No puede exceder el monto disponible para el cheque..."
					else
						if @monto.to_f<=0
							flash[:notice]="Introduzca un monto para el cheque..."
						else
						  #verifica que el periodo este activo
						  @sqlv=" select p.id_ejercicio,p.cns_mes,anio,mes as mmes from periodos p,ejercicios e where activo and cns_mes<13 and e.id_ejercicio=p.id_ejercicio and  '#{@fecha}' between fecha_inicial and fecha_final"
						  @rs=VrCcCredito.find_by_sql(@sqlv)
						  if @rs.length>0
							#aqui va el guardado del cheque
							@sqlg="select * from cc_generar_cheque_ministracion('#{@parametro}','#{@cuenta}','#{@fecha}',#{@monto},#{@ncheque},#{@idc_min})"
							@sqlg+=" as (idmov int,id_ej int,cns_m int,cns_a int,n_cheque int,n_folio int)"
							@id=VrCcCredito.find_by_sql(@sqlg)
							flash[:notice]="La ministraci&oacute;n ha sido contabilizada..."
							@pol="Eg-#{@id[0].n_folio}"
						  else
						  	flash[:notice]="La fecha ingresada corresponde a un periodo contable inexistente o inactivo"
						  end
						end
					end
				end
		
		
		end
		
		#cargar datos 
		@datos=VrCcCredito.find(@parametro)
		@sql="select (nombre_banco||' '||num_cuenta)::varchar(50) as cuenta,(case when cheque then 'Cheque' else 'Trans.' end)::varchar(6) as tipo,"
		@sql+="ref_cheque,fecha,monto,concepto_min::varchar(20),cheque,formato,ch_m.idcredito,ch.idmov,ch.id_ejercicio,ch.cns_mes,ch.cns_asiento,"
		@sql+="nombre_banco,num_cuenta from cc_conceptos_ministracion co_m,cc_cheques_ministracion ch_m,"
		@sql+="cheques ch,cuentas_bancarias cb,bancos b where ch_m.idcredito=#{@parametro} and ch_m.idc_min=co_m.idc_min and ch_m.idmov=ch.idmov"
		@sql+=" and ch.idcuenta=cb.idcuenta and cb.idbanco=b.idbanco"
		@conteo=VrCcCredito.count_by_sql(@sql)
		@datocheque=VrCcCredito.find_by_sql(@sql)
		if @conteo>0
			@sql1="select sum(monto) as monto from cc_conceptos_ministracion co_m,cc_cheques_ministracion ch_m,"
			@sql1+="cheques ch,cuentas_bancarias cb,bancos b where ch_m.idcredito=#{@parametro} and ch_m.idc_min=co_m.idc_min and ch_m.idmov=ch.idmov"
			@sql1+=" and ch.idcuenta=cb.idcuenta and cb.idbanco=b.idbanco"
			@dat=VrCcCredito.find_by_sql(@sql1)
			@entregado=@dat[0].monto
		else
			@entregado=0
		end
		@sql2="select (num_cuenta||', [ '||nombre_banco||','||sucursal||' ]')::varchar(70) as cuenta,c.idcuenta,cns_cheque,clave_gral,formato,imagen,"
	 	@sql2+="nombre_banco,num_cuenta from cuentas_bancarias cb,bancos b,cuentas c where c.idcuenta=cb.idcuenta and cb.idbanco=b.idbanco"
		@cuentas=VrCcCredito.find_by_sql(@sql2)
		#carga los datos de la cuenta para el combo
		@cuentacombo=[[]]
		@count=0
		for el in @cuentas
		     @cuentacombo[@count]=el.cuenta,el.idcuenta
			 @count+=1
		end
		@sql3="select concepto_min::varchar(30),idc_min from cc_conceptos_ministracion order by 2"
		@conceptos=VrCcCredito.find_by_sql(@sql3)
		#carga los datos de los conceptos
		@conceptocombo=[[]]
		@count=0
		for el in @conceptos
		     @conceptocombo[@count]=el.concepto_min,el.idc_min
			 @count+=1
		end
		
  end
  
  def printcheque
  	 @parametro=params[:id][:id]
	 	@solicitud=params[:id][:solicitud]
     @monto=params[:datos][:monto]
	 @fecha=mes(params[:datos][:fecha],1)
  	 @nombre=params[:datos][:nombrecli]
	 @totletra=numlet(@monto.to_s)
	 
  end
  def printpoliza
  		 @parametro=params[:id][:id]
	 	@solicitud=params[:id][:solicitud]
  		@sql="select * from sucursales,config"
		@sql2="select (nombre_banco||' '||num_cuenta)::varchar(50) as cuenta,(case when cheque then 'Cheque' else 'Trans.' end)::varchar(6) as tipo,"
		@sql2+="ref_cheque,fecha,monto,concepto_min::varchar(20),cheque,formato,ch_m.idcredito,ch.idmov,ch.id_ejercicio,ch.cns_mes,ch.cns_asiento,"
	 	@sql2+="nombre_banco,num_cuenta from cc_conceptos_ministracion co_m,cc_cheques_ministracion ch_m,"
	 	@sql2+="cheques ch,cuentas_bancarias cb,bancos b where ch_m.idcredito=#{@parametro} and ch_m.idc_min=co_m.idc_min and ch_m.idmov=ch.idmov"
	 	@sql2+=" and ch.idcuenta=cb.idcuenta and cb.idbanco=b.idbanco"
		
		@datos=VrCcPrincipale.find_by_sql(@sql)
		@config=VrCcPrincipale.find_by_sql(@sql2)
		@id_ejercicio=@config[0].id_ejercicio
		@cns_mes=@config[0].cns_mes
		@cns_asiento=@config[0].cns_asiento
		@sql3="select * from consultora084.v_asientos where id_ejercicio=#{@id_ejercicio} and cns_mes=#{@cns_mes} and cns_asiento=#{@cns_asiento}"
		@sql4="select * from consultora084.v_partidas where id_ejercicio=#{@id_ejercicio}and cns_mes=#{@cns_mes} and cns_asiento=#{@cns_asiento}"
		@asiento=VrCcPrincipale.find_by_sql(@sql3)
		@partida=VrCcPrincipale.find_by_sql(@sql4)
		@datcli=VrCcCredito.find(@parametro)
		@poliza="P&oacute;liza de #{@asiento[0].tipo_poliza}   [#{@config[0].tipo}]"
		@fecha=mes(@config[0].fecha,2)
		@fechalet=mes(@config[0].fecha,1)
		@monto=@config[0].monto
		@montolet=numlet(@config[0].monto)
		@nombrecli=@datcli.cliente
		if @config[0].cheque==true
			@concepto="N&uacute;mero de Cheque"
			@firma="Firma de recibido"
		else
			@concepto="Referencia"
			@firma=""
		end
		
  end
  
  def quitacoma(valor)
  		val=valor
		val=val.gsub(/[$]/,'')
		val=val.gsub(/[,]/,'')
		return val
  end
end
