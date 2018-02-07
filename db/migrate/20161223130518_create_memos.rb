class CreateMemos < ActiveRecord::Migration[5.0]
  def change
    create_table :memos do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.integer :url_id
      t.integer :public, default: 1
      t.timestamps
    end
  end
end
