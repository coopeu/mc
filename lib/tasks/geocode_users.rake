# frozen_string_literal: true

namespace :users do
  desc 'Update user coordinates based on municipality using precise coordinates'
  task geocode: :environment do
    puts 'Starting geocoding of users based on municipalities...'

    total_users = User.where(approved: true).count
    updated_count = 0

    User.where(approved: true).find_each do |user|
      if user.municipi.present?
        old_lat = user.latitude
        old_lng = user.longitude

        MunicipalityGeocoderService.update_user_coordinates(user)

        if user.latitude != old_lat || user.longitude != old_lng
          updated_count += 1
          puts "Updated #{user.nom} #{user.cognom1} (#{user.municipi}): #{user.latitude}, #{user.longitude}"
        end
      end
    end

    puts 'Geocoding complete!'
    puts "Total users: #{total_users}"
    puts "Updated coordinates: #{updated_count}"
    puts "Users without municipality: #{total_users - User.where(approved: true).where.not(municipi: [nil, '']).count}"
  end

  desc 'Show geocoding statistics'
  task geocode_stats: :environment do
    puts 'Geocoding Statistics'
    puts '=' * 50

    total_users = User.where(approved: true).count
    geocoded_users = User.where(approved: true).where.not(latitude: nil, longitude: nil).count
    missing_coords = total_users - geocoded_users

    puts "Total approved users: #{total_users}"
    puts "Users with coordinates: #{geocoded_users}"
    puts "Users missing coordinates: #{missing_coords}"
    puts "Percentage geocoded: #{(geocoded_users.to_f / total_users * 100).round(2)}%"

    puts "\nBy Province:"
    User.where(approved: true).group(:provincia).count.each do |province, count|
      geocoded_in_province = User.where(approved: true, provincia: province).where.not(latitude: nil).count
      puts "  #{province}: #{count} total, #{geocoded_in_province} geocoded"
    end

    puts "\nBy Municipality (top 10):"
    User.where(approved: true).where.not(municipi: [nil, '']).group(:municipi).count.sort_by do |_, v|
      -v
    end.first(10).each do |municipi, count|
      puts "  #{municipi}: #{count} users"
    end
  end
end
