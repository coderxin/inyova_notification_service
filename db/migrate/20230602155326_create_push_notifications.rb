# frozen_string_literal: true

class CreatePushNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :push_notifications do |t|
      t.belongs_to :notification
      t.belongs_to :user

      t.string :state
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :push_notifications, [:notification_id, :user_id], unique: true
  end
end
