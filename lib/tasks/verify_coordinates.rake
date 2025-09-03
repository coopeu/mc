# frozen_string_literal: true

namespace :geolocation do
  desc 'Verify coordinates in geolocatmunicipis table'
  task verify_coordinates: :environment do
    puts 'Checking coordinates in geolocatmunicipis table...'

    # Valid ranges for Catalonia
    min_lng = 0.0
    max_lng = 3.5 # Approximate longitude range for Catalonia
    min_lat = 40.0
    max_lat = 43.0 # Approximate latitude range for Catalonia

    puts "Valid ranges: Longitude #{min_lng}-#{max_lng}, Latitude #{min_lat}-#{max_lat}"

    # Check all municipalities
    results = ActiveRecord::Base.connection.execute('SELECT name, x, y FROM geolocatmunicipis')

    results.each do |row|
      name = row['name']
      lng = row['x'].to_f
      lat = row['y'].to_f

      if lng < min_lng || lng > max_lng || lat < min_lat || lat > max_lat
        puts "⚠️  #{name}: OUT OF RANGE - Longitude: #{lng}, Latitude: #{lat}"
      else
        puts "✅ #{name}: Longitude: #{lng}, Latitude: #{lat}"
      end
    end

    puts 'Verification complete!'
  end
end
