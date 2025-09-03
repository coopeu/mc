#!/usr/bin/env ruby
# frozen_string_literal: true

# Check table structure and update user coordinates

require_relative '../config/environment'

puts 'Checking table structure and updating coordinates...'
puts '=' * 60

# Check available tables
tables = ActiveRecord::Base.connection.tables
puts "Available tables: #{tables.join(', ')}"

# Find the correct table
geoloc_table = tables.find { |t| t.include?('municip') }
puts "Found geolocation table: #{geoloc_table}"

if geoloc_table
  # Check table structure
  columns = ActiveRecord::Base.connection.columns(geoloc_table)
  puts "\nColumns in #{geoloc_table}:"
  columns.each { |col| puts "  #{col.name}: #{col.type}" }

  # Check users table
  user_columns = ActiveRecord::Base.connection.columns('users')
  puts "\nColumns in users:"
  user_columns.each { |col| puts "  #{col.name}: #{col.type}" }

  # Check if we have the required columns
  has_lat_long = user_columns.any? { |c| c.name == 'latitude' && c.name == 'longitude' }

  if has_lat_long
    puts "\nUsers table has latitude/longitude columns"

    # Count users
    total_users = User.count
    puts "Total users: #{total_users}"

    # Try to update coordinates
    begin
      # Get sample data from geolocation table
      sample = ActiveRecord::Base.connection.execute("SELECT * FROM #{geoloc_table} LIMIT 1")
      puts "\nSample geolocation data:"
      sample.each { |row| puts row.inspect }

      # Update coordinates
      sql = <<-SQL.squish
        UPDATE users u
        INNER JOIN #{geoloc_table} g ON u.municipi = g.municipi
        SET u.latitude = g.y,
            u.longitude = g.x
        WHERE u.municipi IS NOT NULL
          AND g.municipi IS NOT NULL
          AND g.x IS NOT NULL
          AND g.y IS NOT NULL;
      SQL

      puts "\nExecuting update..."
      ActiveRecord::Base.connection.execute(sql)

      updated_count = User.where.not(latitude: nil).count
      puts "Updated #{updated_count} users with coordinates"
    rescue StandardError => e
      puts "Error during update: #{e.message}"

      # Try alternative column names
      puts 'Trying alternative column names...'

      # Check what columns are available
      geoloc_cols = columns.map(&:name)
      if geoloc_cols.include?('name')
        sql = <<-SQL.squish
          UPDATE users u
          INNER JOIN #{geoloc_table} g ON u.municipi = g.name
          SET u.latitude = g.y,
              u.longitude = g.x
          WHERE u.municipi IS NOT NULL
            AND g.name IS NOT NULL
            AND g.x IS NOT NULL
            AND g.y IS NOT NULL;
        SQL

        puts "Using 'name' column instead of 'municipi'..."
        ActiveRecord::Base.connection.execute(sql)

        updated_count = User.where.not(latitude: nil).count
        puts "Updated #{updated_count} users with coordinates"
      end
    end

  else
    puts 'Users table does not have latitude/longitude columns'
  end
else
  puts 'No geolocation table found'
end

# Show final results
updated_count = User.where.not(latitude: nil).count
puts "\nFinal result: #{updated_count} users have coordinates"
