class CreateReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :reminders do |t|
      t.text :content
      t.datetime :time

      t.timestamps
    end
  end
end
