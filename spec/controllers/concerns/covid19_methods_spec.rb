require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	describe 'メソッドexec_commamd_weatherは' do
		context 'COVID19感染者情報を要求するメッセージを受け取ったとき' do
			it '天気情報をリプライする' do
				post :callback, body: generate_posts("\"コロナウイルスの状況どんな感じ？\""), as: :json
				expect(assigns(:message)[:text]).to include '感染者数'
			end
		end
    end
end

RSpec.describe OdysseaController, type: :controller do 
	describe 'Ilias-Botは' do
		context 'manualをGETメソッドで受け取ったとき' do
			it "リクエストが成功する" do
				get :covid19
				expect(response.status).to eq(200)
			end
			it "JSON['status']を'SUCCESS'にして返す" do
				get :covid19
				json = JSON.parse(response.body)
				expect(json['status']).to eq 'SUCCESS'
			end
			it "JSON['message']を適切なメッセージにして返す" do
				get :covid19
				json = JSON.parse(response.body)
				expect(json['message']).to include '感染者数'
			end
			it "JSON['expression']を'normal'にして返す" do
				get :covid19
				json = JSON.parse(response.body)
				expect(json['expression']).to eq 'normal'
			end
		end
    end
end