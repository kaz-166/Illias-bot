require 'rails_helper'

RSpec.describe LinebotController, type: :controller do  
	context '「おはよう」というメッセージを受け取ったとき' do
		it '「おはようございます。」と返す' do
			post :callback, body: generate_posts("\"おはよう\""), as: :json
			expect(assigns(:message)[:text]).to eq 'おはようございます。'
		end
	end

	context '登録されていないメッセージを受け取ったとき' do
		it '何もリプライを返さない' do
			post :callback, body: generate_posts("\"ああ～\""), as: :json
			expect(assigns(:message)[:text]).to eq nil
		end
	end
end