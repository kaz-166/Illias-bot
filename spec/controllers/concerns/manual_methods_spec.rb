require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	context 'マニュアルの使い方のメッセージを受け取ったとき' do
		it 'ユーザズマニュアルのリンクを返す' do
			post :callback, body: generate_posts("\"使い方が分かんない\""), as: :json
			expect(assigns(:message)[:text]).to include 'ユーザズマニュアルのリンクを貼っておきますね。'
		end
	end
end

RSpec.describe OdysseaController, type: :controller do 	
	describe 'Ilias-Botは' do
		context 'manualをGETメソッドで受け取ったとき' do
			it "リクエストが成功する" do
				get :manual
				expect(response.status).to eq(200)
			end
			it "JSON['status']を'SUCCESS'にして返す" do
				get :manual
				json = JSON.parse(response.body)
				expect(json['status']).to eq 'SUCCESS'
			end
			it "JSON['message']を適切なメッセージにして返す" do
				get :manual
				json = JSON.parse(response.body)
				expect(json['message']).to include 'ユーザズマニュアルのリンクを貼っておきますね。'
			end
			it "JSON['expression']を'happy'にして返す" do
				get :manual
				json = JSON.parse(response.body)
				expect(json['expression']).to eq 'happy'
			end
		end
	end
end