# ------------------------------------------
# @name:  天気情報
# @id:  3
# ------------------------------------------
# @abstract
# 天気情報を返します。
# 天気情報の取得はOpenWeatherMapのAPIを使用しています。
# ------------------------------------------
# @params [JSON]
# location: 取得したい天気情報の地名 
# hour:     X時間後の天気情報を取得する。0～4までの指定が可能
# ------------------------------------------
# @returns [JSON]
# status:  処理結果
# message: 応答メッセージ文字列
# expression: 表情コード
# ------------------------------------------
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
	ERROR_MASSEAGE_WEATHER = "すみません、問題が発生したようです..."

	def self.exec_command_weather(params) # コマンド要求時の天気情報を取得しメッセージを返す
		if (params['location'] == nil) || (params['hour'] == nil)
			return Settings.status.invalid_params, 'ん？何かルールを守っていないようですね...？', Settings.expression.angry
		else
			return generate_response_message(params['location'], params['hour'])
		end
	end

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

		def self.generate_response_message(location, hour) # Line Botで返答する文章を生成
			location_ja = location_to_ja(location.capitalize)	
			if location_ja == nil
				return Settings.status.invalid_params, "そんな地名はありませんよ？", Settings.expression.angry 
			end
			hour_message = hour_to_ja(hour.to_i)
			if hour_message == nil
				return Settings.status.invalid_params, "その時間までの予測はできないです...", Settings.expression.confused
			end
			begin
				response = callback_open_weather_map(location.capitalize)
			rescue
				return Settings.status.api_callback_error, "天気情報が取得できませんでした。", Settings.expression.confused
			end
			# callback_open_weather_mapで取得したJSONから天候情報を抽出する
			temp    = extract_from_json(TEMP, hour.to_i, response)
			weather = extract_from_json(WEATHER, hour.to_i, response)
			
			return Settings.status.success, "#{hour_message}の#{location_ja}の天気は#{weather}。\n気温は#{temp}℃です。"
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

		def self.hour_to_ja(hour)
			if    hour == 0
				'現在'
			elsif hour == 1
				'1時間後'
			elsif hour == 2
				'2時間後'
			elsif hour == 3
				'3時間後'
			elsif hour == 4
				'4時間後'
			else
				nil
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
				nil
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
end