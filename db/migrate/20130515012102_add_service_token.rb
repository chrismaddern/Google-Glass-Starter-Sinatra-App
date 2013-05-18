class AddServiceToken < ActiveRecord::Migration
  def up
    add_column :users, :service_token_expires_at, :string
    add_column :users, :service_token, :string
  end

  def down
  end
end
