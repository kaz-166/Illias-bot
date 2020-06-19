class OdysseaController < ApplicationController
	
	def callback
		status, reply, expr = MethodSelecter.exec(params)
		render json: { status: status, message: reply, expression: expr }
	end
    
end
