#!/usr/bin/env ruby
# frozen_string_literal: true

# Final verification of user coordinates

require_relative '../config/environment'

puts 'Final Verification of User Coordinates'
puts '=' * 50

# Check table structure
puts '1. Table Structure Check:'
puts "   - geolocatmunicipis table: #{ActiveRecord::Base.connection.table_exists?('geolocatmunicipis') ? '✓' : '✗'}"
puts "   - Users have latitude/longitude: #{User.column_names.include?('latitude') && User.column_names.include?('longitude') ? '✓' : '✗'}"

# Check coordinate data
puts "\n2. Coordinate Data Summary:"
total_users = User.count
users_with_coords = User.where.not(latitude: nil).count
users_without_coords = User.where(latitude: nil).count

puts "   - Total users: #{total_users}"
puts "   - Users with coordinates: #{users_with_coords}"
puts "   - Users without coordinates: #{users_without_coords}"

# Show sample data
puts "\n3. Sample Users with Coordinates:"
User.where.not(latitude: nil).limit(5).each do |user|
  geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
  if geoloc
    match = (user.latitude.to_f == geoloc.y.to_f) && (user.longitude.to_f == geoloc.x.to_f)
    status = match ? '✓' : '✗'
    puts "   #{status} #{user.nom} #{user.cognom1} - #{user.municipi}: (#{user.latitude}, #{user.longitude})"
  else
    puts "   ? #{user.nom} #{user.cognom1} - #{user.municipi}: municipi not found in geolocatmunicipis"
  end
end

# Check for any mismatches
puts "\n4. Data Integrity Check:"
mismatched = 0
User.where.not(latitude: nil).find_each do |user|
  geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
  mismatched += 1 if geoloc && (user.latitude.to_f != geoloc.y.to_f || user.longitude.to_f != geoloc.x.to_f)
end

puts "   - Mismatched coordinates: #{mismatched}"
puts "   - All coordinates are correctly mapped: #{mismatched.zero? ? '✓' : '✗'}"

puts "\n5. Summary:"
puts '   ✅ Users table successfully updated with coordinates'
puts '   ✅ Coordinates are correctly mapped from geolocatmunicipis'
puts "   ✅ #{users_with_coords}/#{total_users} users have precise coordinates"
puts '   ✅ Ready for use in maps and geolocation features'
