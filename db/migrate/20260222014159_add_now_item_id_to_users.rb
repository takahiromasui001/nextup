class AddNowItemIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :now_item, foreign_key: { to_table: :items, on_delete: :nullify }
  end
end
