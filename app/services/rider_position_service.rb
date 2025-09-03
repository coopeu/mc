# frozen_string_literal: true

# Service to get rider position coordinates based on user's municipi
class RiderPositionService
  # Get the position (x,y) coordinates for a given user
  # @param user [User] the user object
  # @return [Hash] coordinates hash with :x and :y keys, or nil if not found
  def self.get_position(user)
    return nil if user&.municipi.blank?

    geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
    return nil unless geoloc

    {
      x: geoloc.x,
      y: geoloc.y,
      municipi: user.municipi
    }
  end

  # Get the position (x,y) coordinates for a given user ID
  # @param user_id [Integer] the user ID
  # @return [Hash] coordinates hash with :x and :y keys, or nil if not found
  def self.get_position_by_id(user_id)
    user = User.find_by(id: user_id)
    return nil unless user

    get_position(user)
  end

  # Get the position (x,y) coordinates for a given municipi name
  # @param municipi_name [String] the municipi name
  # @return [Hash] coordinates hash with :x and :y keys, or nil if not found
  def self.get_position_by_municipi(municipi_name)
    return nil if municipi_name.blank?

    geoloc = Geolocalitzaciomunicipi.find_by(name: municipi_name)
    return nil unless geoloc

    {
      x: geoloc.x,
      y: geoloc.y,
      municipi: municipi_name
    }
  end

  # Get all riders with their positions
  # @return [Array] array of hashes with user info and coordinates
  def self.get_all_rider_positions
    User.joins('INNER JOIN geolocatmunicipis ON users.municipi = geolocatmunicipis.name')
        .where(approved: true)
        .select('users.id, users.nom, users.cognom1, users.municipi, geolocatmunicipis.x, geolocatmunicipis.y')
        .map do |user|
      {
        user_id: user.id,
        name: "#{user.nom} #{user.cognom1}",
        municipi: user.municipi,
        x: user.x,
        y: user.y
      }
    end
  end

  # Update a user's latitude and longitude based on their municipi
  def self.update_user_coordinates(user_or_id)
    user = user_or_id.is_a?(User) ? user_or_id : User.find_by(id: user_or_id)
    return { success: false, error: 'User not found' } unless user
    return { success: false, error: 'User has no municipi' } if user.municipi.blank?

    geoloc = Geolocalitzaciomunicipi.find_by(name: user.municipi)
    return { success: false, error: "No geolocation data for municipi: #{user.municipi}" } unless geoloc

    # In geolocatmunicipis, x = longitude, y = latitude
    user.longitude = geoloc.x
    user.latitude = geoloc.y

    if user.save
      { success: true, user: user, coordinates: { latitude: user.latitude, longitude: user.longitude } }
    else
      { success: false, error: "Failed to save user: #{user.errors.full_messages.join(', ')}" }
    end
  end

  # Update all approved users' coordinates
  def self.update_all_user_coordinates
    results = {
      total: User.where(approved: true).count,
      updated: 0,
      failed: 0,
      skipped: 0,
      errors: []
    }

    User.where(approved: true).find_each do |user|
      if user.municipi.blank?
        results[:skipped] += 1
        next
      end

      result = update_user_coordinates(user)
      if result[:success]
        results[:updated] += 1
      else
        results[:failed] += 1
        results[:errors] << "User ID #{user.id}: #{result[:error]}"
      end
    end

    results
  end
end
