# frozen_string_literal: true

class CreateLiders < ActiveRecord::Migration[7.1]
  def change
    create_table :liders do |t|
      t.references :user, foreign_key: true
      t.references :sortide, foreign_key: true

      t.timestamps
    end
  end
end
