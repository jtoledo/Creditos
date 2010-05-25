
	function envia(param)
	{
			var val=param["pago[importe]"].value
			if(!isNaN(val)){
				if(val>0)
					document.forms[1].pagodistri.value=val
				else{
				alert('La cantidad debe ser mayor a 0')
				param["pago[importe]"].value=0.00
				document.forms[1].pagodistri.value=0.00
			}	
			}
			else{
				alert('Debe Introducir Números')
				param["pago[importe]"].value=0.00
				document.forms[1].pagodistri.value=0.00
			}
				
		
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
	
	function distribuye()
	{
		var upd=document.getElementById("preview")
		var upd2=document.getElementById("viewcheque")
		upd.innerHTML="<h3>Detalle de pagar&eacute; cliente</h3>"
		upd2.innerHTML="<h3>Pagare(s) del cliente</h3>"
		document.forms[0].commit.disabled=false	
	}
	
	function updatedet()
	{
		var upd=document.getElementById("preview")
		upd.innerHTML="<h3>Detalle de pagar&eacute; cliente</h3>"
	}
	
	
	function extraef(formula)
	{
		var fecha=formula["pago[fecha(3i)]"].value+"-"+formula["pago[fecha(2i)]"].value+"-"+formula["pago[fecha(1i)]"].value
		document.forms[1].fecha.value=fecha	
		
	}
	function extraefcombo(formula)
	{
		var fecha=formula["pago[fecha(3i)]"].value+"-"+formula["pago[fecha(2i)]"].value+"-"+formula["pago[fecha(1i)]"].value
		document.forms[1].fecha.value=fecha	
		formula["commit"].disabled=true
		
	}
	