class StoreItem < ActiveRecord::Migration
  def up
    create_table :items do |t|
      t.string  :item_id
      t.boolean :published
    end
  end

  def down
    drop_table :items
  end
end
