class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  include WeatherMethods

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
              message = {
                type: 'text',
                text: response
              }
              client.reply_message(event['replyToken'], message)
            end
          end
      }
      head :ok
  end

  private
    def parse_command(event)
      if event.message['text'].include?("おはよう")
        'おはようございます。'
      elsif event.message['text'].include?("天気")
        exec_command_weather(event.message['text'])
      end
    end
end