# frozen_string_literal: true

class MapsController < ApplicationController
  def riders
    # Query users with their exact geolocation from users table (latitut, longitut columns in Catalan)
    @users = User.where(approved: true)
                 .where.not(latitut: nil, longitut: nil)
                 .preload(:plan, :puntuacio)
                 .with_attached_avatar

    respond_to do |format|
      format.html
      format.json { render json: riders_geojson_with_coordinates }
    end
  end

  private

  def riders_geojson_with_coordinates
    features = @users.filter_map { |user| user_to_geojson_with_coordinates(user) }

    {
      type: 'FeatureCollection',
      features: features
    }
  end

  def user_to_geojson_with_coordinates(user)
    # Use coordinates directly from the users table (Catalan column names: latitut, longitut)
    longitude = user.longitut.to_f
    latitude = user.latitut.to_f

    # Skip users without valid coordinates
    return nil if longitude.zero? || latitude.zero?

    # Ensure coordinates are within valid ranges
    return nil unless (-180..180).cover?(longitude) && (-90..90).cover?(latitude)

    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [longitude, latitude] # [lng, lat] format for GeoJSON
      },
      properties: {
        id: user.id,
        name: "#{user.nom} #{user.cognom1}",
        municipi: user.municipi,
        comarca: user.comarca,
        provincia: user.provincia,
        plan: user.plan&.nom,
        level: user.puntuacio&.user_level,
        avatar_url: user.avatar.attached? ? rails_blob_url(user.avatar) : nil,
        profile_url: user_path(user)
      }
    }
  end
end
