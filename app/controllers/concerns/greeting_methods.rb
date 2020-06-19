# ------------------------------------------
# 機能名:  挨拶
# 機能ID:  1
# ------------------------------------------
# @params
# なし
# ------------------------------------------
# @returns [JSON]
# status:  処理結果
# message: 応答メッセージ文字列
# ------------------------------------------
module GreetingMethods
  extend ActiveSupport::Concern

	def self.exec_command_greeting
		return 'SUCCESS', 'おはようございます。'
	end

end