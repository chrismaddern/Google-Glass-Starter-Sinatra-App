class AddNotifyTable < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.string  :payload
      t.string  :userToken
    end
  end

  def down
    drop_table :notifications
  end
end
