require 'rails_helper'
require 'json'

RSpec.describe LinebotController, type: :controller do

    def generate_posts(txt)
      txt_pref = "{\"events\":
          [{\"type\":\"message\",\"replyToken\":\"xxxx\",
            \"source\":{\"userId\":\"xxxx\",\"type\":\"user\"},
            \"timestamp\":1591852909179,\"mode\":\"active\",
            \"message\":{\"type\":\"text\",\"id\":\"xxxx\",\"text\":"
      txt_suff = "}}],\"destination\":\"xxxx\"}"
      txt_pref + txt + txt_suff
    end

    describe 'POST CALLBACK API' do
        it 'should be success' do
          post :callback, body: generate_posts("\"おはよう\""), as: :json
          expect(response.status).to eq (200) 
        end
      context 'with a message about greetings' do
        it 'should reply 「おはようございます。」' do
          post :callback, body: generate_posts("\"おはよう\""), as: :json
          expect(assigns(:message)[:text]).to eq 'おはようございます。'
        end
      end
      context 'with an invalid message' do
        it 'should not reply' do
          post :callback, body: generate_posts("\"ああ～\""), as: :json
          expect(assigns(:message)[:text]).to eq nil
        end
      end
      context 'with a message about weather' do
        it 'should reply message about arbitary Prefs weather' do
          post :callback, body: generate_posts("\"ねーねー！天気教えてー！\""), as: :json
          expect(assigns(:message)[:text]).to include '現在の千葉県の天気は'
        end
        it 'should reply message about Tokyos weather' do
          post :callback, body: generate_posts("\"東京の天気ってどうなってるー？\""), as: :json
          expect(assigns(:message)[:text]).to include '現在の東京都の天気は'
        end
        it 'should reply message about Osakas weather' do
          post :callback, body: generate_posts("\"大阪の天気が知りたいなぁ\""), as: :json
          expect(assigns(:message)[:text]).to include '現在の大阪府の天気は'
        end
        it 'should reply message about arbitary Prefs weather of 1 hours after' do
          # 全角半角を区別しない
          post :callback, body: generate_posts("\"1時間後の天気ってどうなんだろう？？\""), as: :json
          expect(assigns(:message)[:text]).to include '1時間後の千葉県の天気は'
          post :callback, body: generate_posts("\"１時間後の天気ってどうなんだろう？？\""), as: :json
          expect(assigns(:message)[:text]).to include '1時間後の千葉県の天気は'
        end
        it 'should reply message about Tokyos weather of 2 hours after' do
          # 全角半角を区別しない
          post :callback, body: generate_posts("\"2時間後の東京の天気ってどうなんだろう？？\""), as: :json
          expect(assigns(:message)[:text]).to include '2時間後の東京都の天気は'
          post :callback, body: generate_posts("\"２時間後の東京の天気ってどうなんだろう？？\""), as: :json
          expect(assigns(:message)[:text]).to include '2時間後の東京都の天気は'
        end
        it 'should reply message about Mies weather of 3 hours after' do
          # 全角半角を区別しない
          post :callback, body: generate_posts("\"3時間後の三重の天気ってどうなんだろう？？\""), as: :json
          expect(assigns(:message)[:text]).to include '3時間後の三重県の天気は'
          post :callback, body: generate_posts("\"３時間後の三重の天気ってどうなんだろう？？\""), as: :json
          expect(assigns(:message)[:text]).to include '3時間後の三重県の天気は'
        end
      end
    end
end
