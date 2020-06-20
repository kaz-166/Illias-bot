class OdysseaController < ApplicationController
	
	def callback
		result = MethodSelecter.exec(params)
		render json: { status: result['status'], message: result['message'], expression: result['expression'] }
	end
    
end
