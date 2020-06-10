module WeatherMethods
  extend ActiveSupport::Concern
	require 'json'
	require 'open-uri'

	API_KEY  = ENV['OPEN_WEATHER_API_KEY']	# OpenWeatherのAPI_KEYを環境変数にセットすること
	BASE_URL = "http://api.openweathermap.org/data/2.5/forecast"

	WEATHER = 'weather'
	TEMP = 'temp'

	# 悪天候の発生をを検知してユーザに通知するメソッド
	def alert_weather
		if rainy?

		end
	end
	# コマンド要求時の天気情報を取得し、メッセージを返すメソッド
	def exec_command_weather
		generate_response_message
	end
	
	def rainy?
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
		def generate_response_message
			location = "Tokyo"
			response = callback_open_weather_map(location)
			# callback_open_weather_mapで取得したJSONから天候情報を抽出する
			temp    = extract_from_json(TEMP, response)
			weather = extract_from_json(WEATHER, response)
			return_with_exception if ((temp == nil) || (weather == nil))

			location = '東京都' if location == "Tokyo"
			"現在の#{location}の天気は#{weather}。\n気温は#{temp}℃です。"
		end
		
		# Web APIを使用して天候情報を取得するメソッド
		def callback_open_weather_map(location)
			 response = open(BASE_URL + "?q=#{location},jp&APPID=#{API_KEY}")
			 JSON.parse(response.read)
		end

		# 天候情報を日本語に変換するメソッド
		# OpenWeatherMapのAPIに日本語モードも存在するが、かなり怪しい日本語なので自作する
		def weather_to_ja(weather)
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

		def extract_from_json(element, response)
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

		def return_with_exception
			return 'すみません。問題が発生したようです...'
		end

end