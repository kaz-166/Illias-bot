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
        it 'should reply message about Arbitary Prefs weather' do
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
      end
    end
end
