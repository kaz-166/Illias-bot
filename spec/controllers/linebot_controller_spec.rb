require 'rails_helper'
require 'json'

RSpec.describe LinebotController, type: :controller do
  describe 'POST CALLBACK API' do
    context 'with any message' do
      it 'should be success' do
        post :callback, body: generate_posts("\"テスト\""), as: :json
        expect(response.status).to eq (200) 
      end
    end
  end
end

