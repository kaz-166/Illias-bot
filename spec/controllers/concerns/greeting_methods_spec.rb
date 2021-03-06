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

RSpec.describe OdysseaController, type: :controller do 
	describe 'Ilias-Botは' do
		context 'greetingsをGETメソッドで受け取ったとき' do
			it "リクエストが成功する" do
				get :greetings
				expect(response.status).to eq(200)
			end
			it "JSON['status']を'SUCCESS'にして返す" do
				get :greetings
				json = JSON.parse(response.body)
				expect(json['status']).to eq 'SUCCESS'
			end
			it "JSON['message']を'おはようございます。'にして返す" do
				get :greetings
				json = JSON.parse(response.body)
				expect(json['message']).to eq 'おはようございます。'
			end
			it "JSON['expression']を'happy'にして返す" do
				get :greetings
				json = JSON.parse(response.body)
				expect(json['expression']).to eq 'happy'
			end
		end
	end
end