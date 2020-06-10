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

	# 悪天候の発生をを検知してユーザに通知するメソッド
	def self.alert
    cl ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
    if bad_weather?('Chiba')
      content = '現在はあまり天候がよくないみたいです。'
    else
      content = '現在は天候が良好のようですね。'
    end
    message = {
                type: 'text',
                text: content
              }
    cl.push_message(PUSH_TO_ID, message)
	end
	
	# コマンド要求時の天気情報を取得し、メッセージを返すメソッド
	def self.exec_command_weather(message)
		generate_response_message(message)
	end
	
	def self.bad_weather?(location)
		response = callback_open_weather_map(location)
		weather = extract_from_json(WEATHER, response)
		if (weather == '雨') || (weather == '雪')
			true
		else
			false
		end
	end
	
	private
		# Line Botで返答する文章を生成するメソッド
		def self.generate_response_message(message)
			location = extract_location(message)
			response = callback_open_weather_map(location)
			# callback_open_weather_mapで取得したJSONから天候情報を抽出する
			temp    = extract_from_json(TEMP, response)
			weather = extract_from_json(WEATHER, response)
			return_with_exception if ((temp == nil) || (weather == nil))

			location = location_to_ja(location)
			"現在の#{location}の天気は#{weather}。\n気温は#{temp}℃です。"
		end
		
		# Web APIを使用して天候情報を取得するメソッド
		def self.callback_open_weather_map(location)
			 response = open(BASE_URL + "?q=#{location},jp&APPID=#{API_KEY}")
			 JSON.parse(response.read)
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

		# 天候情報を日本語に変換するメソッド
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

		def self.extract_from_json(element, response)
			if element == WEATHER
				weather_to_ja(response['list'][0]['weather'][0]['main'])
			elsif element == TEMP
				temp = response['list'][0]['main']['temp']
				temp = (temp.to_i - 273).to_s	# ケルビン単位で取得されるためセルシウス度に変換
				temp
			else
				nil
			end
		end

		def self.return_with_exception
			return 'すみません。問題が発生したようです...'
		end

end