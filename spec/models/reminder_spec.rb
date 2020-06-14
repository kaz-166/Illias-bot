require 'rails_helper'
require 'date'

RSpec.describe Reminder, type: :model do
  it 'should be succeed in create' do
    rem = Reminder.new(content: "a", time: DateTime.now)
    expect(rem.save).to eq true
  end
  it 'should be failed in an empty content' do
    rem = Reminder.new(content: "", time: DateTime.now)
    expect(rem.save).to eq false
  end
  it 'should be failed in an empty time' do
    rem = Reminder.new(content: "a", time: "")
    expect(rem.save).to eq false
  end
end
