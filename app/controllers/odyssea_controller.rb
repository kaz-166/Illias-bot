class OdysseaController < ApplicationController

	def greetings
		result = {'status' => Settings.status.success, 'message' => '', 'expression' => Settings.expression.normal }
		result['status'],  result['message'], result['expression'] = GreetingMethods.exec_command_greeting
		render json: { status: result['status'], message: result['message'], expression: result['expression'] }
	end

	def manual
		result = {'status' => Settings.status.success, 'message' => '', 'expression' => Settings.expression.normal }
		result['status'],  result['message'], result['expression'] = ManualMethods.exec_commamd_manual
		render json: { status: result['status'], message: result['message'], expression: result['expression'] }
	end

	def weather
		result = {'status' => Settings.status.success, 'message' => '', 'expression' => Settings.expression.normal }
		result['status'],  result['message'], result['expression'] = WeatherMethods.exec_command_weather(params)
		render json: { status: result['status'], message: result['message'], expression: result['expression'] }
	end

	# def reminder
	# end

    
end
