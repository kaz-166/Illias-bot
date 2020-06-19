# ------------------------------------------
# @name:  マニュアル
# @id:  2
# ------------------------------------------
# @abstract
# ユーザーズマニュアルのリンクを返します。
# ------------------------------------------
# @params
# なし
# ------------------------------------------
# @returns [JSON]
# status:  処理結果
# message: 応答メッセージ文字列
# expression: 表情コード
# ------------------------------------------
module ManualMethods
	extend ActiveSupport::Concern

	def self.exec_commamd_manual
		return Settings.status.success, "ユーザズマニュアルのリンクを貼っておきますね。\n" + 'https://ilias-bot.herokuapp.com/manual', Settings.expression.happy
	end

end