INIT_REMIND_MODE    = 0
CONTENT_REMIND_MODE = 1
TIME_REMIND_MODE    = 2

module ReminderMethods
	extend ActiveSupport::Concern

	REGEX_DAY  = /今日|明日|([0-9]+月[0-9]+)|([0-9]+\/[0-9]+)/
	REGEX_TIME = /([0-9]+:[0-9]+)|([0-9]+時[0-9]+)|([0-9]+時)/
	ERROR_MESSAGE_DAY_EMPTY   = '日付の指定もお願いします。'
	ERROR_MESSAGE_DAY_INVALID = '日付がおかしいですよ？'
	ERROR_MESSAGE_TIME        = '時間がおかしいですよ？'
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
		case ($remind_state)
		when INIT_REMIND_MODE
			$remind_state = CONTENT_REMIND_MODE
			'了解です。リマインド内容を教えてください。'
		when CONTENT_REMIND_MODE
			$remind_state = TIME_REMIND_MODE
			'了解です。リマインドする時間を教えてください。'
		when TIME_REMIND_MODE
			remind_time(message)
		else
			'不正な分岐です。'
		end
	end

	private
		def self.remind_time(message)
			if (day = REGEX_DAY.match(message)) != nil
				if day.to_a[0].include?('今日') || day.to_a[0].include?('明日')
					day_elements = [day.to_a[0]]
				else
					day_elements = day.to_a[0].split(/月|\//)
					if valid_day?(day_elements[0].to_i, day_elements[1].to_i)
					else
						return ERROR_MESSAGE_DAY_INVALID
					end
				end
			else 
				return ERROR_MESSAGE_DAY_EMPTY
			end

			if (time = REGEX_TIME.match(message)) != nil
				ti_array = time.to_a[0].split(/時|:/)
				if valid_time?(ti_array[0].to_i, ti_array[1].to_i)
					$remind_state = INIT_REMIND_MODE
						if ti_array.length == 1
							if (day_elements[0] == '今日') || (day_elements[0] == '明日')
								"了解しました。#{day_elements[0]}の#{ti_array[0]}時にまた連絡しますね。"
							else
								"了解しました。#{day_elements[0]}月#{day_elements[1]}日の#{ti_array[0]}時にまた連絡しますね。"
							end
						else
							if (day_elements[0] == '今日') || (day_elements[0] == '明日')
								"了解しました。#{day_elements[0]}の#{ti_array[0]}時#{ti_array[1]}分にまた連絡しますね。"
							else
								"了解しました。#{day_elements[0]}月#{day_elements[1]}日の#{ti_array[0]}時#{ti_array[1]}分にまた連絡しますね。"
							end
						end
				else
					return ERROR_MESSAGE_TIME
				end
			else
				return ERROR_MESSAGE_TIME
			end
		end

		# @input [Integer, Integer]
		# @output [Boolean]
		def self.valid_time?(hour, minute)
			(hour <= 24) && (minute <= 59) ? true : false 
		end

		# @input [Integer, Integer]
		# @output [Boolean]
		def self.valid_day?(month, day)
			if month <= 12
				case (day)
				when 1, 3, 5, 7, 8, 10, 12
					day <= 31 ? true : false  
				when 4, 6, 9, 11
					day <= 30 ? true : false  
				when 2
					# [Check!] 閏年の考慮をすること。
					day <= 29 ? true : false  
				else
					false
				end
			else
				false
			end
		end
end