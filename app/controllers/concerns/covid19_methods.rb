# ------------------------------------------
# @name:  COVID19情報
# @id:  4
# ------------------------------------------
# @abstract
# 新型コロナウイルス(COVID-19)に関する情報を提供します
# ------------------------------------------
# @params
# なし
# ------------------------------------------
# @returns [JSON]
# status:  処理結果
# message: 応答メッセージ文字列
# expression: 表情コード
# ------------------------------------------

API_URL = "https://api.covid19api.com/dayone/country/japan"

module Covid19Methods
    extend ActiveSupport::Concern
    require 'json'
    require 'open-uri'
    
    # def self.exec_command_covid19(country, time)
    def self.exec_command_covid19
        country = 'japan'
        begin
            result = JSON.parse(open(API_URL).read)
        rescue
            return Settings.status.success, "データが取得できませんでした...", Settings.expression.confused
        end
        return Settings.status.success, "累計感染者数は#{result[result.length-1]['Confirmed']}です。", Settings.expression.normal
	end
end


