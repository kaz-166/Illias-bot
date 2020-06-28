class OdysseaController < ApplicationController
	
	def callback
		result = MethodSelecter.exec(params)
		render json: { status: result['status'], message: result['message'], expression: result['expression'] }
	end

	def greetings
		result = {'status' => Settings.status.success, 'message' => '', 'expression' => Settings.expression.normal }
		result['status'],  result['message'], result['expression'] = GreetingMethods.exec_command_greeting
		render json: { status: result['status'], message: result['message'], expression: result['expression'] }
	end

	# def manual
	# end

	# def weather
	# end

	# def reminder
	# end

    
end
