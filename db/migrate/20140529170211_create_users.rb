class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.boolean :is_deleted
      t.timestamps
    end
    User.create(name: "example", username: "example967", email:"example@example.com", password_hash: '$2a$10$UBuLrWmZtzw5HBT.n24nKuqoPTdGbT2VzQLaHQMxfRKbI/lvx7tdC', password_salt: '$2a$10$UBuLrWmZtzw5HBT.n24nKu',  is_deleted: false) #Test123
  end
  def down
    drop_table :users
  end
end
