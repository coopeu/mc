# frozen_string_literal: true

module UsersGeocodingHelper
  def get_catalan_coordinates(municipi, _comarca)
    # Manual coordinate mapping for major Catalan municipalities
    coordinates = {
      # Barcelona area
      'Barcelona' => { lat: 41.3851, lng: 2.1734 },
      'Terrassa' => { lat: 41.5604, lng: 2.0084 },
      'Sabadell' => { lat: 41.5463, lng: 2.1074 },
      'Sant Cugat del Vallès' => { lat: 41.4667, lng: 2.0833 },
      'Castelldefels' => { lat: 41.2803, lng: 1.9767 },
      'Mollet del Vallès' => { lat: 41.5403, lng: 2.2131 },
      'Vilafranca del Penedès' => { lat: 41.3467, lng: 1.6994 },
      'Manresa' => { lat: 41.7253, lng: 1.8236 },
      'Calella' => { lat: 41.6133, lng: 2.6544 },
      'Sant Andreu de Llavaneres' => { lat: 41.5733, lng: 2.4822 },
      'Premià de Mar' => { lat: 41.4897, lng: 2.3608 },
      'Santa Maria d\'Oló' => { lat: 41.8733, lng: 2.0356 },
      'Vallbona d\'Anoia' => { lat: 41.5200, lng: 1.7078 },
      'Bescanó' => { lat: 41.9667, lng: 2.7333 },

      # Girona area
      'Girona' => { lat: 41.9833, lng: 2.8167 },
      'Figueres' => { lat: 42.2667, lng: 2.9667 },
      'Blanes' => { lat: 41.6744, lng: 2.7906 },
      'Lloret de Mar' => { lat: 41.6997, lng: 2.8472 },
      'Olot' => { lat: 42.1833, lng: 2.4833 },
      'Ripoll' => { lat: 42.2000, lng: 2.1833 },

      # Lleida area
      'Lleida' => { lat: 41.6167, lng: 0.6167 },
      'Tàrrega' => { lat: 41.6472, lng: 1.1397 },
      'Balaguer' => { lat: 41.7917, lng: 0.8056 },
      'Mollerussa' => { lat: 41.6306, lng: 0.8944 },
      'La Seu d\'Urgell' => { lat: 42.3583, lng: 1.4583 },

      # Tarragona area
      'Tarragona' => { lat: 41.1167, lng: 1.2500 },
      'Reus' => { lat: 41.1556, lng: 1.1083 },
      'Tortosa' => { lat: 40.8125, lng: 0.5208 },
      'Valls' => { lat: 41.2861, lng: 1.2497 },
      'Cambrils' => { lat: 41.0667, lng: 1.0500 },
      'Salou' => { lat: 41.0767, lng: 1.1417 },
      'Amposta' => { lat: 40.7125, lng: 0.5792 },
      'Gandesa' => { lat: 41.0500, lng: 0.4389 }
    }

    # Try exact match first
    return coordinates[municipi] if coordinates[municipi]

    # Try partial matches for municipalities
    coordinates.each do |key, coords|
      return coords if municipi.include?(key) || key.include?(municipi)
    end

    # Return nil if no match found
    nil
  end
end
