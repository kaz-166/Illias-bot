require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	context 'with a message asking how to use this app' do
		it 'should replay message about manual page with link' do
			post :callback, body: generate_posts("\"使い方が分かんない\""), as: :json
			expect(assigns(:message)[:text]).to include 'ユーザズマニュアルのリンクを貼っておきますね。'
		end
	end
end