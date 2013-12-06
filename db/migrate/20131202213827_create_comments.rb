class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.text :comment
      t.integer :post_id
      t.timestamps
    end
    Comment.create(comment: "Praesent accumsan neque vel dui pretium iaculis. Suspendisse potenti. Phasellus interdum ut ligula vel fringilla. Praesent suscipit diam at fringilla molestie.", post_id: 1)
  end
  def down
    drop_table :posts
  end
end
