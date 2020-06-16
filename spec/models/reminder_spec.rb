require 'rails_helper'
require 'date'

RSpec.describe Reminder, type: :model do
  it 'データの作成が成功すること' do
    rem = Reminder.new(content: "a", time: DateTime.now)
    expect(rem.save).to eq true
  end
  it 'contextカラムは空ではいけない' do
    rem = Reminder.new(content: "", time: DateTime.now)
    expect(rem.save).to eq false
  end
  it 'timeカラムは空では行けない' do
    rem = Reminder.new(content: "a", time: "")
    expect(rem.save).to eq false
  end
end
