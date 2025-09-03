# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :login_time

      t.timestamps
    end
  end
end
