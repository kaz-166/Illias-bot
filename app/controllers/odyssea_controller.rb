class OdysseaController < ApplicationController
	
	def callback
		message = params[:text]
		reply = parse_command(message)
		render json: { status: 'SUCCESS', message: reply }
	end

	private
	def parse_command(message)
		if GreetingMethods.matching?(message)
			GreetingMethods.exec_command_greeting
		elsif WeatherMethods.matching?(message)
			WeatherMethods.exec_command_weather(message)
		elsif ManualMethods.matching?(message)
			ManualMethods.exec_commamd_manual
		elsif ReminderMethods.matching?(message)
			ReminderMethods.exec_commamd_reminder(message)
		else
			# コマンド不一致の場合は何も返さない
		end
	end 
    
end