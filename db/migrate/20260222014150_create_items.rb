class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url
      t.text :memo
      t.integer :action_type
      t.integer :time_bucket
      t.integer :energy
      t.integer :status, null: false, default: 0
      t.datetime :snooze_until

      t.timestamps
    end

    add_index :items, [:user_id, :status]
  end
end
