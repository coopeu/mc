# frozen_string_literal: true

namespace :users do
  desc 'Update user coordinates from geolocatmunicipis table'
  task update_coordinates: :environment do
    puts 'Starting coordinate update for users...'

    # Check if geolocatmunicipis table exists
    unless ActiveRecord::Base.connection.table_exists?('geolocatmunicipis')
      puts 'Error: geolocatmunicipis table does not exist'
      exit 1
    end

    # Check if users table has the new columns
    unless User.column_names.include?('latitude') && User.column_names.include?('longitude')
      puts 'Error: Users table does not have latitude/longitude columns. Please run the migration first.'
      exit 1
    end

    # Count users before update
    total_users = User.count
    users_with_municipi = User.where.not(municipi: [nil, '']).count

    puts "Total users: #{total_users}"
    puts "Users with municipi: #{users_with_municipi}"

    # Update coordinates
    updated_count = 0

    User.find_each do |user|
      next if user.municipi.blank?

      geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
      if geoloc && geoloc.x.present? && geoloc.y.present?
        user.update_columns(
          latitude: geoloc.y,
          longitude: geoloc.x
        )
        updated_count += 1
        print '.'
      else
        print 'X'
      end
    end

    puts "\n\nUpdate complete!"
    puts "Updated #{updated_count} users with coordinates"
    puts "Skipped #{users_with_municipi - updated_count} users (municipi not found in geolocatmunicipis)"

    # Show sample results
    puts "\nSample updated users:"
    User.where.not(latitude: nil).limit(5).each do |user|
      puts "  #{user.nom} #{user.cognom1} - #{user.municipi}: (#{user.latitude}, #{user.longitude})"
    end
  end

  desc 'Verify coordinate updates'
  task verify_coordinates: :environment do
    puts 'Verifying coordinate updates...'

    users_with_coords = User.where.not(latitude: nil)
    puts "Users with coordinates: #{users_with_coords.count}"

    if users_with_coords.any?
      puts "\nFirst 10 users with coordinates:"
      users_with_coords.limit(10).each do |user|
        geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
        if geoloc
          match = (user.latitude.to_f == geoloc.y.to_f) && (user.longitude.to_f == geoloc.x.to_f)
          status = match ? '✓' : '✗'
          puts "  #{status} #{user.nom} #{user.cognom1} - #{user.municipi}: (#{user.latitude}, #{user.longitude})"
        else
          puts "  ? #{user.nom} #{user.cognom1} - #{user.municipi}: municipi not found"
        end
      end
    end

    # Show statistics
    puts "\nStatistics:"
    puts "  Total users: #{User.count}"
    puts "  Users with coordinates: #{User.where.not(latitude: nil).count}"
    puts "  Users without coordinates: #{User.where(latitude: nil).count}"
  end

  desc 'Reset user coordinates'
  task reset_coordinates: :environment do
    puts 'Resetting user coordinates...'

    updated = User.update_all(latitude: nil, longitude: nil)
    puts "Reset coordinates for #{updated} users"
  end
end
