
require 'time'

class Reminder < ApplicationRecord
  validates :content, presence: true
  validates :time,    presence: true
  # validate  :past_time?
  
  # def past_time?
  #  if time.to_time > Time.now 
  #    errors.add(:date, ": 過去の日付は使用できません")
  #  end
  # end
end
