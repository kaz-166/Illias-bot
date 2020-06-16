require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	context 'マニュアルの使い方のメッセージを受け取ったとき' do
		it 'ユーザズマニュアルのリンクを返す' do
			post :callback, body: generate_posts("\"使い方が分かんない\""), as: :json
			expect(assigns(:message)[:text]).to include 'ユーザズマニュアルのリンクを貼っておきますね。'
		end
	end
end