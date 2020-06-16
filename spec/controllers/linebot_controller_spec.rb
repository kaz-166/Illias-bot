require 'rails_helper'
require 'json'

RSpec.describe LinebotController, type: :controller do
  describe '#callbackが' do
    context 'メッセージを受け取ったとき' do
      it '通信成功であること' do
        post :callback, body: generate_posts("\"テスト\""), as: :json
        expect(response.status).to eq (200) 
      end
    end
  end
end

