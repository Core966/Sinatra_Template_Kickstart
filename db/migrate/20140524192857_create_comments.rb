class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.text :comment
      t.boolean :is_deleted
      t.boolean :was_expanded
      t.integer :post_id
      t.integer :user_id
      t.timestamps
    end
    Comment.create(comment: "Praesent accumsan neque vel dui pretium iaculis. Suspendisse potenti. Phasellus interdum ut ligula vel fringilla. Praesent suscipit diam at fringilla molestie.", is_deleted: false, was_expanded: false, post_id: 1, user_id:1)
  end
  def down
    drop_table :comments
  end
end