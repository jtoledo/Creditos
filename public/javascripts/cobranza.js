
	function ocultar(param)
	{
		if(param==1)
		{
			capatpago.style.visibility="visible"
		}
		if(param==2)
		{
			capatpago.style.visibility="hidden"
		}
		
	}

	function setfecha(formula)
	{
		var fecha=formula["pago[fecha(3i)]"].value+"-"+formula["pago[fecha(2i)]"].value+"-"+formula["pago[fecha(1i)]"].value
		document.forms[1]["dist[fecha]"].value=fecha
		document.forms[1]["dist[ficha]"].value=	formula["pago[ficha]"].value
		
	}
	function setfechacombo(formula)
	{
		var fecha=formula["pago[fecha(3i)]"].value+"-"+formula["pago[fecha(2i)]"].value+"-"+formula["pago[fecha(1i)]"].value
		document.forms[1]["dist[fecha]"].value=fecha
		document.forms[1]["dist[ficha]"].value=	formula["pago[ficha]"].value
		document.forms[0]["commit"].disabled=true	
	}
	
	function setdatos(formula)
	{
		var fecha=document.forms[0]["pago[fecha(3i)]"].value+"-"+document.forms[1]["pago[fecha(2i)]"].value+"-"+document.forms[1]["pago[fecha(1i)]"].value
		formula["dist[fecha]"].value=fecha
		formula["dist[ficha]"].value=document.forms[0]["pago[ficha]"].value
		
	}
	
	function validanum(param,vali)
	{
		if(isNaN(param.value)){
			  alert('Se aceptan solo numeros')
			  param.value=0.00
		}
		else
		{
			if(parseFloat(param.value)>parseFloat(vali.value) || param.value<0)
			{
				 alert('El numero que esta capturando es mayor de lo aceptado o menor a 0, verifique...')
			  	 param.value=0.00
			}
		}
	}
	
	function validanum2(param)
	{
		if(isNaN(param.value)){
			  alert('Se aceptan solo numeros')
			  param.value=0.00
		}
		else
		{
			if(param.value<0)
			{
				 alert('No se aceptan numeros negativos, verifique...')
			  	 param.value=0.00
			}
		}
	   //registra la cantidad
	   document.forms[1]["dist[ficha]"].value=document.forms[0]["pago[ficha]"].value
	}
	
	
	function distribuye()
	{
		var upd=document.getElementById("preview")
		upd.innerHTML="<h3>Detalles de pagar&eacute; del cliente</h3>"
		document.forms[0]["commit"].disabled=false
		
	}