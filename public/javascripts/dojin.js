	dojo.require("dojo.widget.TabContainer");
	dojo.require("dojo.widget.LinkPane");
	dojo.require("dojo.widget.ContentPane");
	dojo.require("dojo.widget.LayoutContainer");
	dojo.require("dojo.widget.Checkbox");
	dojo.require("dojo.widget.Menu2");
	dojo.require("dojo.widget.*");
	dojo.hostenv.writeIncludes();
	function doMouseMove() {
	  var newleft=0, newTop = 0
	  
		if ((event.button==1)){
		  newleft=event.clientX
	        if (newleft<0) newleft=0
			curElement.style.left=newleft
	        newtop=event.clientY 
			if (newtop<0) newtop=0
	        curElement.style.top=newtop
	        event.returnValue = false
	        event.cancelBubble = true
			    }
	  }
	
	
	
	function doMouseDown() {
	    if ((event.button==1)) 
		{
		curElement = event.srcElement
		}  
	}
	function envia(param)
		{
			param[0].value=param[2].selectedIndex
			//alert(param[0].selectedIndex)
			param.submit();
		}

	