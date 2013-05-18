class AddUserToken < ActiveRecord::Migration
  def up
    add_column :users, :token, :string
  end

  def down
  end
end
