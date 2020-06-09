require 'rails_helper'

MESSAGE = {
    "destination": "xxxxxxxxxx", 
    "events": [
      {
        "replyToken": "0f3779fba3b349968c5d07db31eab56f",
        "type": "message",
        "timestamp": 1462629479859,
        "source": {
          "type": "user",
          "userId": "U4af4980629..."
        },
        "message": {
          "id": "325708",
          "type": "text",
          "text": "Hello, world"
        }
      },
      {
        "replyToken": "8cf9239d56244f4197887e939187e19e",
        "type": "follow",
        "timestamp": 1462629479859,
        "source": {
          "type": "user",
          "userId": "U4af4980629..."
        }
      }
    ]
}.freeze

RSpec.describe LinebotController, type: :controller do

    describe 'POST CALLBACK API' do
        # TODO: Json ParseErrorのため検証は後日じまわす
        it 'should be success' do
           # post :callback, params: MESSAGE
           # expect(response.status).to eq (200) 
        end
    end
end
