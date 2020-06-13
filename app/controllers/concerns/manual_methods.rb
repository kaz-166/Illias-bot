module ManualMethods
	extend ActiveSupport::Concern

	def self.matching?(message)
		(message.include?('使い方') || message.include?('マニュアル')) ? true : false
	end

	def self.exec_commamd_manual
		"ユーザズマニュアルのリンクを貼っておきますね。\n" +
        'https://ilias-bot.herokuapp.com/manual'
	end

end