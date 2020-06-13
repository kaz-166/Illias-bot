INIT_REMIND_MODE    = 0
CONTENT_REMIND_MODE = 1
TIME_REMIND_MODE    = 2

module ReminderMethods
	extend ActiveSupport::Concern

	# [Check!] テストコードから参照する必要性があったので大域変数として定義したが、不必要にスコープを広げており、本来すべきではない。
	#          おそらく他に方法があると考えられるので要調査。
	$remind_state = INIT_REMIND_MODE

	def self.matching?(message)
		if $remind_state == INIT_REMIND_MODE
			message.include?('リマインド') ? true : false
		elsif $remind_state == CONTENT_REMIND_MODE
			true
		elsif $remind_state == TIME_REMIND_MODE
			true
		else
			# このコードには到達しない
		end
	end

	def self.exec_commamd_reminder(message)
		if $remind_state == INIT_REMIND_MODE
			$remind_state = CONTENT_REMIND_MODE
			'了解です。リマインド内容を教えてください。'
		elsif $remind_state == CONTENT_REMIND_MODE
			$remind_state = TIME_REMIND_MODE
			'了解です。リマインドする時間を教えてください。'
		elsif $remind_state == TIME_REMIND_MODE
			if message.include?(':')
			end
		else
			# このコードには到達しない
		end
	end 
end