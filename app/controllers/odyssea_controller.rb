class OdysseaController < ApplicationController
	
	def callback
		status, reply = MethodSelecter.exec(params)
		render json: { status: status, message: reply }
	end
    
end
