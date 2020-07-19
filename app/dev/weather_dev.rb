# 開発用のRubyスクリプト
require 'json'
require 'open-uri'

API_KEY  = ENV['OPEN_WEATHER_API_KEY']	# OpenWeatherのAPI_KEYを環境変数にセットすること
BASE_URL = "https://api.openweathermap.org/data/2.5/onecall"

WEATHER = 'weather'
TEMP = 'temp'

def main
    weather_forcast("tokyo")
end

def weather_forcast(location)
    # One-Call APIでは都市名を指定してコールすることができず、緯度と経度を
    # パラメータとして渡す必要がある。
    r = city2geocode(location)
    # 緯度と経度の情報を渡し、2日分の天候情報(1時間ごと)を取得する
    r = callback_open_weather_map(r['lat'], r['lon'])['hourly']
    #p r[0]["weather"][0]['main']
    #for weather in r do
    #  p weather['weather'][0]['main']
    #end
    p extract_from_json(WEATHER, 0, r)
    p extract_from_json(TEMP, 0, r)
end

# [IN]  city_name: String
# [OUT] {lat: float, lng: float}
def city2geocode(city_name)
    response = open("https://api.openweathermap.org/data/2.5/weather?q=#{city_name},jp&APPID=#{API_KEY}")
    JSON.parse(response.read)['coord']
end

def callback_open_weather_map(lat, lng) # Web APIを使用して天候情報を取得
    response = open(BASE_URL + "?lat=#{lat}&lon=#{lng}&exclude=minutely,daily&APPID=#{API_KEY}")
    JSON.parse(response.read)
end

# input parameters
# element  抽出する要素
# hours     
# response  
def extract_from_json(element, hours, response)
    if element == WEATHER
        weather_to_ja(response[hours]['weather'][0]['main'])
    elsif element == TEMP
        temp = response[hours]['temp']
        temp = (temp.to_i - 273).to_s	# OpenWeatherAPIでは温度が[K]で取得されるためセルシウス度に変換
        temp
    else
        nil
    end
end

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

if __FILE__ == $0
    main
end