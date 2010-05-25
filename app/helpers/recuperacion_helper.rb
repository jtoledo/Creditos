module RecuperacionHelper
  include AjaxScaffold::Helper
  
  def num_columns
    scaffold_columns.length + 1 
  end
  
  def scaffold_columns
    VrCcCredito.scaffold_columns
  end
   #quitar formato de moneda
  def cnovalido(valor)
  		val=valor
		val=val.gsub(/[.]/,'')
		val=val.gsub(/[-]/,'')
		return val
  end 
end
