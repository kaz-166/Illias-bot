module GreetingMethods
  extend ActiveSupport::Concern

	def self.matching?(message)
		message.include?('おはよう') ? true : false 
	end

	def self.exec_command_greeting
		'おはようございます。'
	end

end