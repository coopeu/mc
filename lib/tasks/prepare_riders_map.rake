# frozen_string_literal: true

namespace :maps do
  desc 'Update user coordinates from geolocatmunicipis table'
  task update_coordinates: :environment do
    puts 'Updating user coordinates from geolocatmunicipis table...'

    # Count users before update
    total_users = User.where(approved: true).count
    users_with_municipi = User.where(approved: true).where.not(municipi: [nil, '']).count
    users_with_coords_before = User.where(approved: true).where.not(latitude: nil, longitude: nil).count

    puts 'Before update:'
    puts "  Total approved users: #{total_users}"
    puts "  Users with municipi: #{users_with_municipi}"
    puts "  Users with coordinates: #{users_with_coords_before}"

    # Direct database update for better performance
    updated_count = 0
    skipped_count = 0

    # Process users in batches to avoid memory issues
    User.where(approved: true).where.not(municipi: [nil, '']).find_in_batches(batch_size: 100) do |users|
      # Get all municipi names in this batch
      municipi_names = users.map(&:municipi).uniq.compact

      # Get all geolocatmunicipis records for these municipis in one query
      geo_records = Geolocalitzaciomunicipi.where(name: municipi_names).index_by(&:name)

      # Process each user
      users.each do |user|
        geo_record = geo_records[user.municipi]

        if geo_record
          # Update user coordinates directly from geolocatmunicipis
          user.latitude = geo_record.y
          user.longitude = geo_record.x

          # Add a small random offset to prevent exact overlapping
          # This creates a more natural distribution within each municipi
          # The offset is small enough (max ~100m) to keep users within their municipi
          lat_offset = (rand - 0.5) * 0.002
          lng_offset = (rand - 0.5) * 0.002

          user.latitude += lat_offset
          user.longitude += lng_offset

          if user.save
            updated_count += 1
            print '.' if (updated_count % 10).zero? # Progress indicator
          end
        else
          skipped_count += 1
        end
      end
    end

    puts "\n"

    # Count users after update
    users_with_coords_after = User.where(approved: true).where.not(latitude: nil, longitude: nil).count

    puts "\nAfter update:"
    puts "  Users with coordinates: #{users_with_coords_after}"
    puts "  Coverage: #{(users_with_coords_after.to_f / total_users * 100).round(2)}%"

    puts "\nUpdate results:"
    puts "  Updated: #{updated_count}"
    puts "  Skipped: #{skipped_count}"

    # Check for users still missing coordinates
    users_missing_coords = User.where(approved: true).where.not(municipi: [nil, '']).where(latitude: nil).or(
      User.where(approved: true).where.not(municipi: [nil, '']).where(longitude: nil)
    )

    if users_missing_coords.any?
      puts "\nUsers with municipi but still missing coordinates:"
      users_missing_coords.limit(10).each do |user|
        puts "  - #{user.nom} #{user.cognom1} (ID: #{user.id}, Municipi: #{user.municipi})"
      end

      puts "  ... and #{users_missing_coords.count - 10} more" if users_missing_coords.count > 10

      # List municipis that don't have corresponding geolocatmunicipis records
      missing_municipis = users_missing_coords.pluck(:municipi).uniq.compact
      existing_geo_municipis = Geolocalitzaciomunicipi.where(name: missing_municipis).pluck(:name)
      truly_missing_municipis = missing_municipis - existing_geo_municipis

      if truly_missing_municipis.any?
        puts "\nMunicipis missing from geolocatmunicipis table:"
        truly_missing_municipis.each do |municipi|
          user_count = User.where(municipi: municipi).count
          puts "  - #{municipi} (#{user_count} users)"
        end
      end
    end

    puts "\nDone!"
  end

  desc 'Prepare all user coordinates for the riders map'
  task prepare_riders: :environment do
    Rake::Task['maps:update_coordinates'].invoke
  end
end
