require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	describe 'method: exec_commamd_reminder' do
		context 'with a message demanding to remind' do
			it 'should reply a message for registration of reminding and go next state' do
				$remind_state = INIT_REMIND_MODE
				post :callback, body: generate_posts("\"リマインド\""), as: :json
				expect(assigns(:message)[:text]).to include '了解です。リマインド内容を教えてください。'
				expect($remind_state).to eq CONTENT_REMIND_MODE
			end
			it 'should reply a message for registration of reminding and go next state' do
				$remind_state = CONTENT_REMIND_MODE
				post :callback, body: generate_posts("\"リマインド\""), as: :json
				expect(assigns(:message)[:text]).to include '了解です。リマインドする時間を教えてください。'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
		end

		context 'with a message about reminding time after registration' do
			it 'should reply a message demanding remind-time OK.1' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"今日の12:11\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。今日の12時11分にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
			it 'should reply a message demanding remind-time OK.2' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"明日の5時45分\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。明日の5時45分にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
			it 'should reply a message demanding remind-time OK.3' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"4/12の18:5\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。4月12日の18時5分にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
			it 'should reply a message demanding remind-time OK.4' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"12月12日の22時\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。12月12日の22時にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
			it 'should reply a message demanding remind-time NG.1' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"今日の27時\""), as: :json
				expect(assigns(:message)[:text]).to include '時間がおかしいですよ？'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
			it 'should reply a message demanding remind-time NG.2' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"今日の23:67\""), as: :json
				expect(assigns(:message)[:text]).to include '時間がおかしいですよ？'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
			it 'should reply a message demanding remind-time NG.3' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"12:13\""), as: :json
				expect(assigns(:message)[:text]).to include '日付の指定もお願いします。'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
			it 'should reply a message demanding remind-time NG.4' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"13月67日の12:13\""), as: :json
				expect(assigns(:message)[:text]).to include '日付がおかしいですよ？'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
		
		# context 'in reminder integration test' do
    #  it 'should be success' do
    #    post :callback, body: generate_posts("\"リマインド\""), as: :json
    #    post :callback, body: generate_posts("\"歯医者\""), as: :json
    #    post :callback, body: generate_posts("\"明日の5時45分\""), as: :json
    #    expect(assigns(:message)[:text]).to include '了解しました。'
    #  end
    # end
		end
	end
end