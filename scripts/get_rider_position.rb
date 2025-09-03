#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to get rider position (x,y) coordinates from geolocatmunicipis table

require_relative '../config/environment'

# Usage examples:
# ruby scripts/get_rider_position.rb --user-id 1
# ruby scripts/get_rider_position.rb --municipi "Barcelona"
# ruby scripts/get_rider_position.rb --all

def print_usage
  puts 'Usage:'
  puts '  ruby scripts/get_rider_position.rb --user-id USER_ID'
  puts '  ruby scripts/get_rider_position.rb --municipi MUNICIPI_NAME'
  puts '  ruby scripts/get_rider_position.rb --all'
  puts '  ruby scripts/get_rider_position.rb --help'
end

def get_position_for_user(user_id)
  position = RiderPositionService.get_position_by_id(user_id)
  if position
    puts "User ID: #{user_id}"
    puts "Municipi: #{position[:municipi]}"
    puts "Coordinates: x=#{position[:x]}, y=#{position[:y]}"
  else
    puts "User not found or no coordinates available for user ID: #{user_id}"
  end
end

def get_position_for_municipi(municipi_name)
  position = RiderPositionService.get_position_by_municipi(municipi_name)
  if position
    puts "Municipi: #{municipi_name}"
    puts "Coordinates: x=#{position[:x]}, y=#{position[:y]}"
  else
    puts "No coordinates found for municipi: #{municipi_name}"
  end
end

def get_all_positions
  positions = RiderPositionService.get_all_rider_positions
  if positions.any?
    puts 'All rider positions:'
    puts '-------------------'
    positions.each do |pos|
      puts "User: #{pos[:name]} (ID: #{pos[:user_id]})"
      puts "Municipi: #{pos[:municipi]}"
      puts "Coordinates: x=#{pos[:x]}, y=#{pos[:y]}"
      puts '---'
    end
  else
    puts 'No rider positions found'
  end
end

# Main execution
if ARGV.include?('--help') || ARGV.empty?
  print_usage
  exit
end

case ARGV[0]
when '--user-id'
  if ARGV[1]
    get_position_for_user(ARGV[1].to_i)
  else
    puts 'Please provide a user ID'
    print_usage
  end
when '--municipi'
  if ARGV[1]
    get_position_for_municipi(ARGV[1])
  else
    puts 'Please provide a municipi name'
    print_usage
  end
when '--all'
  get_all_positions
else
  puts "Invalid option: #{ARGV[0]}"
  print_usage
end
