class IndexController < ApplicationController
  def index
  	 if request.post?
          if  params[:name]!="" and params[:pwd]!=""
                  user=CcUsuario.find_by_username_and_password(params[:name],params[:pwd])

                  if user 
                          session[:nameuser]="#{user.nombre}"
                          session[:usernames]=user.username
  						            #session[:permiso]=user.Permiso
  						            session[:id]=user.id
  						            session[:wrong]=nil
			 
                          redirect_to :controller=>"index",:action=>:menu, :layout=>false
                  else
                          session[:wrong]="NO"
  						            
                          
                  end
            else   
                  session[:wrong]="NO"
						      
            end
       end  
        
	
	if session[:id]
                #redirect_to :action=>:menu,:layout=>false
     else
                session[:id]=nil
                #redirect_to :action=>:index
     end
  end
  def logout
	  session[:id]=nil
	  redirect_to :controller=>"index",:action=>"index"
  end
  
  
  def menu
  
  end
end
