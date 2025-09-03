#!/usr/bin/env ruby
# frozen_string_literal: true

# Direct script to update user coordinates from geolocalitzaciomunicipis

require_relative '../config/environment'

puts 'Starting coordinate update for users...'
puts '=' * 50

# Check if the table exists
begin
  # Try both possible table names
  table_name = nil

  if ActiveRecord::Base.connection.table_exists?('geolocatmunicipis')
    table_name = 'geolocatmunicipis'
  elsif ActiveRecord::Base.connection.table_exists?('geolocalitzaciomunicipis')
    table_name = 'geolocalitzaciomunicipis'
  else
    puts 'Error: Neither geolocatmunicipis nor geolocalitzaciomunicipis table exists'
    exit 1
  end

  puts "Using table: #{table_name}"

  # Check if users table has coordinates columns
  unless User.column_names.include?('latitude') && User.column_names.include?('longitude')
    puts 'Error: Users table does not have latitude/longitude columns'
    exit 1
  end

  # Count users
  total_users = User.count
  users_with_municipi = User.where.not(municipi: [nil, '']).count

  puts "Total users: #{total_users}"
  puts "Users with municipi: #{users_with_municipi}"

  # Update coordinates using direct SQL
  sql = <<-SQL.squish
    UPDATE users u
    INNER JOIN #{table_name} g ON u.municipi = g.municipi
    SET u.latitude = g.y,
        u.longitude = g.x
    WHERE u.municipi IS NOT NULL
      AND g.municipi IS NOT NULL
      AND g.x IS NOT NULL
      AND g.y IS NOT NULL;
  SQL

  puts 'Executing SQL update...'
  ActiveRecord::Base.connection.execute(sql)

  # Get count of updated users
  updated_count = User.where.not(latitude: nil).count

  puts "\nUpdate complete!"
  puts "Updated #{updated_count} users with coordinates"

  # Show sample results
  puts "\nSample updated users:"
  User.where.not(latitude: nil).limit(5).each do |user|
    puts "  #{user.nom} #{user.cognom1} - #{user.municipi}: (#{user.latitude}, #{user.longitude})"
  end
rescue StandardError => e
  puts "Error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
end
