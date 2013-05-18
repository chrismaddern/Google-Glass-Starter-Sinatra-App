class Item < ActiveRecord::Base

attr_accessible :item_id, :published

def self.item_with_id (item_id)
  items = Item.where('item_id = ?', item_id)
  if (items.count(:id) > 0)
    items.first
  else
    nil
  end
end

end