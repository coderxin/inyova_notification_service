# frozen_string_literal: true

class CreateNotificationAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_assignments do |t|
      t.belongs_to :notification
      t.belongs_to :user
      t.datetime :seen_at

      t.timestamps
    end

    add_index :notification_assignments, [:notification_id, :user_id], unique: true
  end
end
