class AddUser < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string  :email
      t.string  :access_token
      t.string  :refresh_token
      t.string  :expires_in
      t.string  :issued_at
      t.boolean :disabled
    end
  end

  def down
    drop_table :users
  end

end
