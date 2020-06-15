require 'rails_helper'

RSpec.describe LinebotController, type: :controller do  
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
end