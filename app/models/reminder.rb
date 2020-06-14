class Reminder < ApplicationRecord
  validates :content, presence: true
  validates :time,    presence: true
end
