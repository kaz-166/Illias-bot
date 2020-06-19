# ------------------------------------------
# @name:  挨拶
# @id:  1
# ------------------------------------------
# @abstract
# 挨拶文を返します。
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
		return Settings.status.success, 'おはようございます。'
	end

end