class CreateMemberPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :member_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt
      t.text :body
      t.datetime :published_at
      t.timestamps
    end

    add_index :member_posts, :slug, unique: true
    add_index :member_posts, :published_at
  end
end
