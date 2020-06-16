require 'rails_helper'

RSpec.describe LinebotController, type: :controller do
	describe 'メソッドexec_commamd_reminderは' do
		context 'リマインドを要求するメッセージを受け取ったとき' do
			it 'ユーザにリマインド内容を要求し、CONTENT_REMIND_MODEに遷移する' do
				$remind_state = INIT_REMIND_MODE
				post :callback, body: generate_posts("\"リマインド\""), as: :json
				expect(assigns(:message)[:text]).to include '了解です。リマインド内容を教えてください。'
				expect($remind_state).to eq CONTENT_REMIND_MODE
			end
			it 'ユーザにリマインド時間を要求し、TIME_REMIND_MODEに遷移する' do
				$remind_state = CONTENT_REMIND_MODE
				post :callback, body: generate_posts("\"リマインド\""), as: :json
				expect(assigns(:message)[:text]).to include '了解です。リマインドする時間を教えてください。'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
		end

		context '日付を「今日」、時間を[XX:XX]形式で受け取ったとき' do
			it '成功コメントをリプライし、INIT_REMIND_MODEに遷移する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"今日の12:11\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。今日の12時11分にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
		end

		context '日付を「明日」、時間を[XX:XX]形式で受け取ったとき' do
			it '成功コメントをリプライし、INIT_REMIND_MODEに遷移する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"明日の5時45分\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。明日の5時45分にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
		end

		context '日付を[XX/XX]形式、時間を[XX:XX]形式で受け取ったとき' do
			it '成功コメントをリプライし、INIT_REMIND_MODEに遷移する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"4/12の18:5\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。4月12日の18時5分にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
		end

		context '日付を[XX時XX分]形式、時間を[XX時]形式で受け取ったとき' do
			it '成功コメントをリプライし、INIT_REMIND_MODEに遷移する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"12月12日の22時\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。12月12日の22時にまた連絡しますね。'
				expect($remind_state).to eq INIT_REMIND_MODE
			end
		end

		context '不正な時間(Hour)が指定されたメッセージを受け取ったとき' do
			it '失敗コメントをリプライし、状態遷移を維持する' do
			$remind_state = TIME_REMIND_MODE
			Reminder.create(content: 'xxx', time: DateTime.now)
			post :callback, body: generate_posts("\"今日の27時\""), as: :json
			expect(assigns(:message)[:text]).to include '時間がおかしいですよ？'
			expect($remind_state).to eq TIME_REMIND_MODE
			end
		end

		context '不正な時間(Minutes)が指定されたメッセージを受け取ったとき' do
			it '失敗コメントをリプライし、状態遷移を維持する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"今日の23:67\""), as: :json
				expect(assigns(:message)[:text]).to include '時間がおかしいですよ？'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
		end

		context '日付が指定されていないメッセージを受け取ったとき' do
			it '失敗コメントをリプライし、状態遷移を維持する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"12:13\""), as: :json
				expect(assigns(:message)[:text]).to include '日付の指定もお願いします。'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
		end

		context '不正な日付が指定されたメッセージを受け取ったとき' do
			it '失敗コメントをリプライし、状態遷移を維持する' do
				$remind_state = TIME_REMIND_MODE
				Reminder.create(content: 'xxx', time: DateTime.now)
				post :callback, body: generate_posts("\"13月67日の12:13\""), as: :json
				expect(assigns(:message)[:text]).to include '日付がおかしいですよ？'
				expect($remind_state).to eq TIME_REMIND_MODE
			end
		end

		context '一連のリマインダ要求メッセージを受け取ったとき' do
			it 'データベースに保存される' do
				$remind_state = INIT_REMIND_MODE
				post :callback, body: generate_posts("\"リマインド\""), as: :json
				expect(assigns(:message)[:text]).to include '了解です。リマインド内容を教えてください。'
				post :callback, body: generate_posts("\"歯医者\""), as: :json
				expect(assigns(:message)[:text]).to include '了解です。リマインドする時間を教えてください。'
				post :callback, body: generate_posts("\"明日の5時45分\""), as: :json
				expect(assigns(:message)[:text]).to include '了解しました。'
				expect(Reminder.last.content).to eq "歯医者"
			end
		end
	end
end