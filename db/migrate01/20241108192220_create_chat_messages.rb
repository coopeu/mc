# frozen_string_literal: true

class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sortide, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
