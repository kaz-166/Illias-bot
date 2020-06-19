require 'date'

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
	ERROR_MESSAGE_DATABASE    = 'すみません、データにアクセスできませんでした。'
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

	# [Refactor!] このメソッド内にコメントのリプライとデータベース操作の両方の機能が入っており、単一責務の原則の観点から望ましくない。
	def self.exec_commamd_reminder(message)
		case ($remind_state)
		when INIT_REMIND_MODE
			$remind_state = CONTENT_REMIND_MODE
			return 'SUCCESS', '了解です。リマインド内容を教えてください。'
		when CONTENT_REMIND_MODE
			# TimeはTIME_REMIND_MODEステートで更新されるのでここでは仮の値を入れている
			rem = Reminder.new(content: message, time: DateTime.now)
			if rem.save
				$remind_state = TIME_REMIND_MODE
				return 'SUCCESS', '了解です。リマインドする時間を教えてください。'
			else
				$remind_state = INIT_REMIND_MODE
				return 'DATABASE_ERROR', ERROR_MESSAGE_DATABASE
			end
		when TIME_REMIND_MODE
			return remind_time(message)
		else
			return 'INTERNAL_ERROR', '不正な分岐です。'
		end
	end

	def self.remind
	end

	private
		def self.remind_time(message)
			return 'PARAMS_ERROR', ERROR_MESSAGE_DAY_EMPTY if (day = REGEX_DAY.match(message)) == nil
			if day.to_a[0].include?('今日')
				day_elements = [day.to_a[0]]
				year = Time.now.year.to_i
				month = Time.now.month.to_i
				day = Time.now.day.to_i
			elsif day.to_a[0].include?('明日')
				day_elements = [day.to_a[0]]
				year = Time.now.next_day(1).year.to_i
				month = Time.now.next_day(1).month.to_i
				day = Time.now.next_day(1).day.to_i
			else
				day_elements = day.to_a[0].split(/月|\//)
				year = Time.now.year.to_i
				month = day_elements[0].to_i
				day = day_elements[1].to_i
				return 'PARAMS_ERROR', ERROR_MESSAGE_DAY_INVALID if !(valid_day?(day_elements[0].to_i, day_elements[1].to_i))
			end

			if (time = REGEX_TIME.match(message)) != nil
				ti_array = time.to_a[0].split(/時|:/)
				if valid_time?(ti_array[0].to_i, ti_array[1].to_i)
					$remind_state = INIT_REMIND_MODE
					rem = Reminder.last
						return 'DATABASE_ERROR', ERROR_MESSAGE_DATABASE if rem.nil?
						if ti_array.length == 1		# 分の指定がない場合
							is_updete_succeed = rem.update(time: Time.new(year, month, day, ti_array[0].to_i, 0, 0))
							return 'DATABASE_ERROR', ERROR_MESSAGE_DATABASE unless is_updete_succeed
							if (day_elements[0] == '今日') || (day_elements[0] == '明日')		
								return 'SUCCESS', "了解しました。#{day_elements[0]}の#{ti_array[0]}時にまた連絡しますね。"
							else
								return 'SUCCESS', "了解しました。#{day_elements[0]}月#{day_elements[1]}日の#{ti_array[0]}時にまた連絡しますね。"
							end
						else
							is_updete_succeed = rem.update(time: Time.new(year, month, day, ti_array[0].to_i, ti_array[1].to_i, 0))
							return 'DATABASE_ERROR', ERROR_MESSAGE_DATABASE unless is_updete_succeed
							if (day_elements[0] == '今日') || (day_elements[0] == '明日')
								return 'SUCCESS', "了解しました。#{day_elements[0]}の#{ti_array[0]}時#{ti_array[1]}分にまた連絡しますね。"
							else
								return 'SUCCESS', "了解しました。#{day_elements[0]}月#{day_elements[1]}日の#{ti_array[0]}時#{ti_array[1]}分にまた連絡しますね。"
							end
						end
				else
					return 'PARAMS_ERROR', ERROR_MESSAGE_TIME
				end
			else
				return 'PARAMS_ERROR', ERROR_MESSAGE_TIME
			end
		end

		# @input  [Integer, Integer]
		# @output [Boolean]
		def self.valid_time?(hour, minute)
			(hour <= 24) && (minute <= 59) ? true : false 
		end

		# @input  [Integer, Integer]
		# @output [Boolean]
		def self.valid_day?(month, day)
			if month <= 12
				case (day)
				# 31日まである月 
				when 1, 3, 5, 7, 8, 10, 12
					day <= 31 ? true : false
				# 30日までの月   
				when 4, 6, 9, 11
					day <= 30 ? true : false  
				# 
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