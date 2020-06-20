require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	describe 'メソッドexec_commamd_weatherは' do
		context '天気情報を要求するメッセージを受け取ったとき' do
			it '天気情報をリプライする' do
				post :callback, body: generate_posts("\"ねーねー！天気教えてー！\""), as: :json
				expect(assigns(:message)[:text]).to include '現在の千葉県の天気は'
			end
		end

		context '東京都の天気情報を要求するメッセージを受け取ったとき' do
			it '東京都の天気情報をリプライする' do
				post :callback, body: generate_posts("\"東京の天気ってどうなってるー？\""), as: :json
				expect(assigns(:message)[:text]).to include '現在の東京都の天気は'
			end
		end

		context '大阪府の天気情報を要求するメッセージを受け取ったとき' do
			it '大阪府の天気情報をリプライする' do
				post :callback, body: generate_posts("\"大阪の天気が知りたいなぁ\""), as: :json
				expect(assigns(:message)[:text]).to include '現在の大阪府の天気は'
			end
		end

		context '1時間後の天気情報を要求するメッセージを受け取ったとき' do
			it '時間後の天気情報をリプライする' do
				# 全角半角を区別しない
				post :callback, body: generate_posts("\"1時間後の天気ってどうなんだろう？？\""), as: :json
				expect(assigns(:message)[:text]).to include '1時間後の千葉県の天気は'
				post :callback, body: generate_posts("\"１時間後の天気ってどうなんだろう？？\""), as: :json
				expect(assigns(:message)[:text]).to include '1時間後の千葉県の天気は'
			end
		end

		context '2時間後の東京の天気情報を要求するメッセージを受け取ったとき' do
			it '2時間後の東京の天気情報をリプライする' do
				# 全角半角を区別しない
				post :callback, body: generate_posts("\"2時間後の東京の天気ってどうなんだろう？？\""), as: :json
				expect(assigns(:message)[:text]).to include '2時間後の東京都の天気は'
				post :callback, body: generate_posts("\"２時間後の東京の天気ってどうなんだろう？？\""), as: :json
				expect(assigns(:message)[:text]).to include '2時間後の東京都の天気は'
			end
		end
		
		context '3時間後の三重の天気情報を要求するメッセージを受け取ったとき' do
			it '3時間後の三重の天気情報をリプライする' do
				# 全角半角を区別しない
				post :callback, body: generate_posts("\"3時間後の三重の天気ってどうなんだろう？？\""), as: :json
				expect(assigns(:message)[:text]).to include '3時間後の三重県の天気は'
				post :callback, body: generate_posts("\"３時間後の三重の天気ってどうなんだろう？？\""), as: :json
				expect(assigns(:message)[:text]).to include '3時間後の三重県の天気は'
			end
		end		
	end
end

RSpec.describe OdysseaController, type: :controller do 
	describe 'Ilias-Botは' do
		context 'id=3, location=nil, hour=nilのJSONをPOSTメソッドで受け取ったとき' do
			# "{\"id\": \"3\", \"location\": \"tokyo\", \"hour\": \"3\"}"
			it "リクエストが成功する" do
				post :callback, body: "{\"id\": \"3\"}", as: :json
				expect(response.status).to eq(200)
			end
			it "JSON['status']を'INVALID PARAMETER'にして返す" do
				post :callback, body: "{\"id\": \"3\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['status']).to eq Settings.status.invalid_params
			end
			it "JSON['message']を適切なメッセージにして返す" do
				post :callback, body: "{\"id\": \"3\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['message']).to eq 'ん？何かルールを守っていないようですね...？'
			end
			it "JSON['expression']を'angry'にして返す" do
				post :callback, body: "{\"id\": \"3\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['expression']).to eq Settings.expression.angry
			end
		end

		context 'locationが不正なJSONを受け取ったとき' do
			it "リクエストが成功する" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"afehkhdfg\", \"hour\": \"0\"}", as: :json
				expect(response.status).to eq(200)
			end
			it "JSON['status']を'INVALID PARAMETER'にして返す" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"afehkhdfg\", \"hour\": \"0\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['status']).to eq Settings.status.invalid_params
			end
			it "JSON['message']を適切なメッセージにして返す" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"afehkhdfg\", \"hour\": \"0\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['message']).to eq 'そんな地名はありませんよ？'
			end
			it "JSON['expression']を'angry'にして返す" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"afehkhdfg\", \"hour\": \"0\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['expression']).to eq Settings.expression.angry
			end
		end
		
		context 'hourが不正なJSONを受け取ったとき' do
			it "リクエストが成功する" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"tokyo\", \"hour\": \"12\"}", as: :json
				expect(response.status).to eq(200)
			end
			it "JSON['status']を'INVALID PARAMETER'にして返す" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"tokyo\", \"hour\": \"12\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['status']).to eq Settings.status.invalid_params
			end
			it "JSON['message']を適切なメッセージにして返す" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"tokyo\", \"hour\": \"12\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['message']).to eq 'その時間までの予測はできないです...'
			end
			it "JSON['expression']を'confused'にして返す" do
				post :callback, body: "{\"id\": \"3\", \"location\": \"tokyo\", \"hour\": \"12\"}", as: :json
				json = JSON.parse(response.body)
				expect(json['expression']).to eq Settings.expression.confused
			end
		end
	end

end