module WeatherMethods
  extend ActiveSupport::Concern

	require 'json'
	require 'open-uri'
 
	# 悪天候の発生をを検知してユーザに通知するメソッド
	def exec_command_weather
		'天気情報を取得しますね'
	end

	private
		# Line Botで返答する文章を生成するメソッド
		def generate_response_message
		end
		
		# Web APIを使用して天候情報を取得するメソッド
		def callback_open_weather_map
			# API_KEY = 'd3108a91a765e95d43c83a97e78125cd'
			# BASE_URL  "http://api.openweathermap.org/data/2.5/forecast"
			# response = open(BASE_URL + "?q=Akashi-shi,jp&APPID=#{API_KEY}")
			# puts JSON.pretty_generate(JSON.parse(response.read))
		end

end