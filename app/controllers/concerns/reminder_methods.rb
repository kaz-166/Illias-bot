module ReminderMethods
	extend ActiveSupport::Concern
	
	REGISTER_MODE 0
	TIME_MODE 1

	@state = REGISTER_MODE

	def self.matching?(message)
		message.include?('リマインド') ? true : false
	end

	def self.exec_commamd_manual

	end 
end