
	function validanum(param)
	{
		if(isNaN(param.value)){
			  alert('Se aceptan solo numeros')
			  param.value=0.00
		}
		else
		{
			if(param.value<0)
			{
				 alert('Las cantidades deben ser Mayor 0, verifique...')
			  	 param.value=0.00
			}
		}
	}