# frozen_string_literal: true

class RemoveTimestampsFromSessions < ActiveRecord::Migration[6.0]
  def change
    remove_column :sessions, :created_at, :datetime
    remove_column :sessions, :updated_at, :datetime
  end
end
