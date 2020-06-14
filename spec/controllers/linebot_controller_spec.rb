require 'rails_helper'
require 'json'

# [Should be refactored!] 各モジュール別にテストコードを切り分けること
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
    context 'with any message' do
      it 'should be success' do
        post :callback, body: generate_posts("\"おはよう\""), as: :json
        expect(response.status).to eq (200) 
      end
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

    context 'with a message asking how to use this app' do
      it 'should replay message about manual page with link' do
        post :callback, body: generate_posts("\"使い方が分かんない\""), as: :json
        expect(assigns(:message)[:text]).to include 'ユーザズマニュアルのリンクを貼っておきますね。'
      end
    end

    context 'with a message demanding to remind' do
      it 'should reply a message for registration of reminding and go next state' do
        $remind_state = INIT_REMIND_MODE
        post :callback, body: generate_posts("\"リマインド\""), as: :json
        expect(assigns(:message)[:text]).to include '了解です。リマインド内容を教えてください。'
        expect($remind_state).to eq CONTENT_REMIND_MODE
      end
      it 'should reply a message for registration of reminding and go next state' do
        $remind_state = CONTENT_REMIND_MODE
        Reminder.create(content: 'xxx', time: DateTime.now)
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
    end
  end
end

