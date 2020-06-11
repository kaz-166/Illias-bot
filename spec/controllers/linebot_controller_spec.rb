require 'rails_helper'
require 'json'

message = "{\"events\":
          [{\"type\":\"message\",\"replyToken\":\"7d13c449e82348fc9d16bd63ee7624cc\",
            \"source\":{\"userId\":\"Ua2877fdb2e552a7ec72a62b58bcd68ff\",\"type\":\"user\"},
            \"timestamp\":1591852909179,\"mode\":\"active\",
            \"message\":{\"type\":\"text\",\"id\":\"12124612377027\",
            \"text\":\"\xE3\x81\x8A\xE3\x81\xAF\xE3\x82\x88\xE3\x81\x86\"}}],
            \"destination\":\"U077218321f6f801bf0825e1ebee8be64\"}"

RSpec.describe LinebotController, type: :controller do

    describe 'POST CALLBACK API' do
        it 'should be success' do
          post :callback, body: message, as: :json
          expect(response.status).to eq (200) 
        end
    end
end
