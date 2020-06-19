# ------------------------------------------
# 機能名:  マニュアル
# 機能ID:  2
# ------------------------------------------
# @params
# なし
# ------------------------------------------
# @returns [JSON]
# status:  処理結果
# message: 応答メッセージ文字列
# ------------------------------------------
module ManualMethods
	extend ActiveSupport::Concern

	def self.exec_commamd_manual
		return 'SUCCESS', "ユーザズマニュアルのリンクを貼っておきますね。\n" + 'https://ilias-bot.herokuapp.com/manual'
	end

end