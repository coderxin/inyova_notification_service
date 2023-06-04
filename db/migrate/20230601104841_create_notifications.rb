# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.date :date, null: false
      t.string :title, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
