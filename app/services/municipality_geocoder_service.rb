# frozen_string_literal: true

class MunicipalityGeocoderService
  # Update a user's coordinates based on their municipi with improved precision
  def self.update_user_coordinates(user)
    return false if user&.municipi.blank?

    # Get base coordinates from geolocatmunicipis
    geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
    return false unless geoloc

    # In geolocatmunicipis, x = longitude, y = latitude
    base_lat = geoloc.y.to_f
    base_lng = geoloc.x.to_f

    # Count users in this municipi to determine if we need to spread them out
    users_in_municipi = User.where(municipi: user.municipi).count

    # If there are multiple users in the same municipi, add a small offset
    if users_in_municipi > 1
      # Calculate a deterministic offset based on user ID to ensure consistency
      # This creates a small grid pattern around the municipality center
      grid_size = Math.sqrt(users_in_municipi).ceil
      position = User.where(municipi: user.municipi).order(:id).pluck(:id).index(user.id) || 0

      row = position / grid_size
      col = position % grid_size

      # Create an offset of up to ±0.003 degrees (roughly ±300 meters)
      lat_offset = (row - (grid_size / 2)) * 0.0006
      lng_offset = (col - (grid_size / 2)) * 0.0006

      user.latitude = base_lat + lat_offset
      user.longitude = base_lng + lng_offset
    else
      # Single user in municipi, use base coordinates
      user.latitude = base_lat
      user.longitude = base_lng
    end

    user.save
  end

  # Update all users' coordinates with improved precision
  def self.update_all_user_coordinates
    results = {
      total: User.where(approved: true).count,
      updated: 0,
      failed: 0,
      skipped: 0
    }

    # First, group users by municipi to process them together
    User.where(approved: true).group_by(&:municipi).each do |municipi, users|
      next if municipi.blank?

      # Get base coordinates for this municipi
      geoloc = Geolocalitzaciomunicipi.find_by(name: municipi)
      unless geoloc
        results[:skipped] += users.count
        next
      end

      # Process all users in this municipi
      users.each_with_index do |user, _index|
        if update_user_coordinates(user)
          results[:updated] += 1
        else
          results[:failed] += 1
        end
      end
    end

    results
  end
end
