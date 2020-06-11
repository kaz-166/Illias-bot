module WeatherMethods
  extend ActiveSupport::Concern
	require 'json'
	require 'open-uri'
	require 'line/bot'  # gem 'line-bot-api'

	PUSH_TO_ID = ENV['PUSH_TO_ID']
	API_KEY  = ENV['OPEN_WEATHER_API_KEY']	# OpenWeatherのAPI_KEYを環境変数にセットすること
	BASE_URL = "http://api.openweathermap.org/data/2.5/forecast"

	WEATHER = 'weather'
	TEMP = 'temp'

	def self.alert # 悪天候の発生をを検知してユーザに通知
		# TODO: OpenWeatherAPIのコールを2回行っており、冗長。パフォーマンス常の観点から要修正。 
    cl ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
    if weather_goes_bad?('Chiba')
			message = {
                type: 'text',
                text: "天候が崩れそうですよ。\n外出の際は傘の準備をお忘れなく。"
              }
			cl.push_message(PUSH_TO_ID, message)
		elsif weather_goes_good?('Chiba')
			message = {
				type: 'text',
				text: '天候が回復しそうです。'
			}
			cl.push_message(PUSH_TO_ID, message)
    end
	end
	
	def self.exec_command_weather(message) # コマンド要求時の天気情報を取得しメッセージを返す
		generate_response_message(message)
	end
	
	def self.weather_goes_bad?(location)
		response = callback_open_weather_map(location)
		# 現在の天候と1時間後の天候を比較し、天候が崩れる場合はTrueを返す
		weather_now = extract_from_json(WEATHER, 0, response)
		weather_1h_after = extract_from_json(WEATHER, 1, response)
		if (!(weather_now == '雨') || (weather_now == '雪')) &&
			 ((weather_1h_after == '雨') || (weather_1h_after == '雪'))
			true
		else
			false
		end
	end

	def self.weather_goes_good?(location)
		response = callback_open_weather_map(location)
		# 現在の天候と1時間後の天候を比較し、天候が崩れる場合はTrueを返す
		weather_now = extract_from_json(WEATHER, 0, response)
		weather_1h_after = extract_from_json(WEATHER, 1, response)
		if ((weather_now == '雨') || (weather_now == '雪')) &&
			 (!(weather_1h_after == '雨') || (weather_1h_after == '雪'))
			true
		else
			false
		end
	end
	
	private
		def self.callback_open_weather_map(location) # Web APIを使用して天候情報を取得
			response = open(BASE_URL + "?q=#{location},jp&APPID=#{API_KEY}")
			JSON.parse(response.read)
		end

		def self.generate_response_message(message) # Line Botで返答する文章を生成
			location = extract_location(message)
			response = callback_open_weather_map(location)
			# callback_open_weather_mapで取得したJSONから天候情報を抽出する
			hour, hour_message = extract_hours(message)
			temp    = extract_from_json(TEMP, hour, response)
			weather = extract_from_json(WEATHER, hour, response)
			return_with_exception if ((temp == nil) || (weather == nil))

			location = location_to_ja(location)
			"#{hour_message}の#{location}の天気は#{weather}。\n気温は#{temp}℃です。"
		end

		def self.extract_from_json(element, hours, response)
			if element == WEATHER
				weather_to_ja(response['list'][hours]['weather'][0]['main'])
			elsif element == TEMP
				temp = response['list'][hours]['main']['temp']
				temp = (temp.to_i - 273).to_s	# OpenWeatherAPIでは温度が[K]で取得されるためセルシウス度に変換
				temp
			else
				nil
			end
		end
		
		# @message [String]
		# @output [Integer, String]
		def self.extract_hours(message)
			if    message.include?('1時間後') || message.include?('１時間後')
				return 1, '1時間後'
			elsif message.include?('2時間後') || message.include?('２時間後')
				return 2, '2時間後'
			elsif message.include?('3時間後') || message.include?('３時間後')
				return 3, '3時間後'
			elsif message.include?('4時間後') || message.include?('４時間後')
				return 4, '4時間後'
			else
				return 0, '現在'
			end
		end

		def self.extract_location(message)
			if message.include?('東京')
				'Tokyo'
			elsif message.include?('千葉')
				'Chiba'
			elsif message.include?('神奈川')
				'Kanagawa'
			elsif message.include?('埼玉')
				'Saitama'
			elsif message.include?('茨城')
				'Ibaraki'
			elsif message.include?('愛知')
				'Aichi'
			elsif message.include?('三重')
				'Mie'
			elsif message.include?('栃木')
				'Tochigi'
			elsif message.include?('福島')
				'Fukushima'
			elsif message.include?('大阪')
				'Osaka'
			elsif message.include?('京都')
				'Kyoto'
			else
				'Chiba'
			end
		end

		def self.location_to_ja(location)
			if location == 'Tokyo'
				'東京都'
			elsif location == 'Chiba'
				'千葉県'
			elsif location == 'Kanagawa'
				'神奈川県'
			elsif location == 'Saitama'
				'埼玉県'
			elsif location == 'Ibaraki'
				'茨城県'
			elsif location == 'Aichi'
				'愛知県'
			elsif location == 'Mie'
				'三重県'
			elsif location == 'Tochigi'
				'栃木県'
			elsif location == 'Fukushima'
				'福島県'
			elsif location == 'Osaka'
				'大阪府'
			else
				'東京都'
			end
		end

		# 天候情報を日本語に変換
		# OpenWeatherMapのAPIに日本語モードも存在するが、かなり怪しい日本語なので自作する
		def self.weather_to_ja(weather)
			if    weather == 'Clear'
				'晴れ'
			elsif weather == 'Clouds'
				'曇り'
			elsif weather == 'Rain'
				'雨'
			elsif weather == 'Snow'
				'雪'
			else
				nil
			end
		end

		def self.return_with_exception
			return 'すみません。問題が発生したようです...'
		end

end