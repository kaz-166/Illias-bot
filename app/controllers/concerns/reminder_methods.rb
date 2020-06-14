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
			'不正な分岐です。'
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
			if (time = /[0-9]+:[0-9]+/.match(message)) != nil
				if (day = /今日|明日|([0-9]+月[0-9]+日)|([0-9]+\/[0-9]+)/.match(message)) != nil
					$remind_state = INIT_REMIND_MODE
					"了解しました。#{day}の#{time.to_a[0].gsub!(':', '時')}分にまた連絡しますね。"
				else
					'日付の指定もお願いします。'
				end
			elsif (time = /[0-9]+時[0-9]+分/.match(message)) != nil 
				if (day = /今日|明日|([0-9]+月[0-9]+日)|([0-9]+\/[0-9]+)/.match(message)) != nil
					$remind_state = INIT_REMIND_MODE
					"了解しました。#{day}の#{time.to_a[0]}にまた連絡しますね。"
				else
					'日付の指定もお願いします。'
				end
			else
				'時間がおかしいですよ？'
			end
		else
			'不正な分岐です。'
		end
	end 
end