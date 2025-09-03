# frozen_string_literal: true

class CreateInscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :inscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sortide, null: false, foreign_key: true

      t.timestamps
    end
  end
end
