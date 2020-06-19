# 
# routing: Post '/callback' => 'LinbotController#callback'
# Line-Botの各種設定を行う
# このコントローラではLine-Bot機能を使用するための設定のみを行い、
# 各種のロジックは/concerns以下のModuleに実装する。
# 詳細機能のためのロジックをここに書くのは避けること
#
# ただし、LINEクライアントも同じアプリで実装しているため
# Lineクライアント->Ilias-Botの解釈は例外的に本コントローラで行う
#
class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効にする
  protect_from_forgery :except => [:callback]

  def client
      @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
      body = request.body.read
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
      head :bad_request
      end

      events = client.parse_events_from(body)
      events.each{ |event|
          # LINEアプリケーションから送られてきた文書を解析し、parse_commandメソッドで返答文を取得する
          response = parse_command(event)
          case event
          when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
              @message = {
                type: 'text',
                text: response
              }
              client.reply_message(event['replyToken'], @message)
            end
          end
      }
      head :ok
  end

  private
    def parse_command(event)
      params = {}
      if event.message['text'].include?('おはよう') 
        params.store('id', '1')
      elsif (event.message['text'].include?('使い方') || event.message['text'].include?('マニュアル'))
        params.store('id', '2')
      elsif event.message['text'].include?('天気')
        location = extract_weather_location_params(event.message['text'])
        hour     = extract_weather_hour_params(event.message['text'])
        params.store('id', '3')
        params.store('location', location)
        params.store('hour', hour)
      elsif ReminderMethods.matching?(event.message['text'])
        params.store('id', '4')
        params.store('message', event.message['text'])
      else
      end

      MethodSelecter.exec(params)['message']
    end

    def extract_weather_hour_params(message)
			if    message.include?('1時間後') || message.include?('１時間後')
				return 1
			elsif message.include?('2時間後') || message.include?('２時間後')
				return 2
			elsif message.include?('3時間後') || message.include?('３時間後')
				return 3
			elsif message.include?('4時間後') || message.include?('４時間後')
				return 4
			else
				return 0
			end
    end

    def extract_weather_location_params(message)
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
end