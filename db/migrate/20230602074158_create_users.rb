# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :admin, default: false
      t.string :device_token

      t.timestamps
    end

    add_index :users, :email, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
