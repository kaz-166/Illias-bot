module WeatherMethods
  extend ActiveSupport::Concern

	require 'json'
	require 'open-uri'
	# Rubyではメソッド内の定数定義は禁止なのでメソッド外に記載する
	API_KEY  = ENV['OPEN_WEATHER_API_KEY']	# OpenWeatherのAPI_KEYを環境変数にセットすること
	BASE_URL = "http://api.openweathermap.org/data/2.5/forecast"

	# 悪天候の発生をを検知してユーザに通知するメソッド
	def exec_command_weather
		generate_response_message
	end

	private
		# Line Botで返答する文章を生成するメソッド
		def generate_response_message
			location = "Tokyo"
			response = callback_open_weather_map(location)
			p response['list'][0]['main']['temp']
			temp = response['list'][0]['main']['temp']

			if location == "Tokyo"
				location = '東京'
			end

			temp = temp.to_i - 273
			temp = temp.to_s
			"#{location}の気温は#{temp}℃です。"
		end
		
		# Web APIを使用して天候情報を取得するメソッド
		def callback_open_weather_map(location)
			 response = open(BASE_URL + "?q=#{location},jp&APPID=#{API_KEY}")
			 JSON.parse(response.read)
		end

end