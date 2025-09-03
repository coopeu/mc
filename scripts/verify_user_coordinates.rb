# !/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

puts 'Verifying user coordinates distribution...'
puts '=' * 50

# Count users with coordinates
total_users = User.where(approved: true).count
users_with_coords = User.where(approved: true).where.not(latitude: nil, longitude: nil).count
percentage = (users_with_coords.to_f / total_users * 100).round(2)

puts "Total approved users: #{total_users}"
puts "Users with coordinates: #{users_with_coords} (#{percentage}%)"

# Check for duplicate coordinates
coords = User.where(approved: true).where.not(latitude: nil, longitude: nil)
             .pluck(:latitude, :longitude)
duplicates = coords.group_by { |c| c }.select { |_, v| v.size > 1 }

puts "\nUsers with identical coordinates: #{duplicates.size} groups"
if duplicates.any?
  puts 'Top 5 duplicate coordinate groups:'
  duplicates.first(5).each do |coords, occurrences|
    puts "  Coordinates #{coords.inspect}: #{occurrences.size} users"

    # Find users with these coordinates
    users = User.where(latitude: coords[0], longitude: coords[1]).limit(3)
    users.each do |user|
      puts "    - #{user.nom} #{user.cognom1} (#{user.municipi})"
    end
  end
end

# Check coordinate ranges
lat_range = User.where(approved: true).where.not(latitude: nil)
                .pick('MIN(latitude)', 'MAX(latitude)')
lng_range = User.where(approved: true).where.not(longitude: nil)
                .pick('MIN(longitude)', 'MAX(longitude)')

puts "\nCoordinate ranges:"
puts "  Latitude:  #{lat_range[0]} to #{lat_range[1]}"
puts "  Longitude: #{lng_range[0]} to #{lng_range[1]}"

# Check for users with coordinates but no municipi
inconsistent = User.where(approved: true)
                   .where.not(latitude: nil, longitude: nil)
                   .where(municipi: [nil, ''])
                   .count

puts "\nUsers with coordinates but no municipi: #{inconsistent}"

puts "\nDone!"
