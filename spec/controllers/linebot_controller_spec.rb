require 'rails_helper'
require 'json'

message = '{
          "destination": "xxxxxxxxxx", 
          "events":
            {
              "replyToken": "0f3779fba3b349968c5d07db31eab56f",
              "type": "message",
              "timestamp": "1462629479859",
              "source": {
                "type": "user",
                "userId": "U4af4980629..."
              },

              "message": {
                "id": "325708",
                "type": "text",
                "text": "Hello, world"
              }
            }
          }'

          test = '{"aaa": "bbb", "ccc": "ddd"}'

RSpec.describe LinebotController, type: :controller do

    describe 'POST CALLBACK API' do
        # TODO: Json ParseErrorのため検証は後日じまわす
        it 'should be success' do
          p test
          post :callback, body: test, as: :json
          expect(response.status).to eq (200) 
        end
    end
end
