# frozen_string_literal: true

class CreateSortideComments < ActiveRecord::Migration[7.1]
  def change
    create_table :sortide_comments do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :sortide, null: false, foreign_key: true

      t.timestamps
    end
  end
end
