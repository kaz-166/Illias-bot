require 'rails_helper'
require 'date'

RSpec.describe Reminder, type: :model do
  describe 'Reminderモデルは' do
    it 'データの作成が成功する' do
      rem = Reminder.new(content: "a", time: DateTime.now)
      expect(rem.save).to eq true
    end
    it 'contextカラムは空ではいけない' do
      rem = Reminder.new(content: "", time: DateTime.now)
      expect(rem.save).to eq false
    end
    it 'timeカラムは空ではいけない' do
      rem = Reminder.new(content: "a", time: "")
      expect(rem.save).to eq false
    end
  end
end
