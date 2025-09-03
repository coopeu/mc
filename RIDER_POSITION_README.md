# Rider Position Service

This service provides functionality to get rider position (x,y) coordinates based on the user's municipi from the geolocatmunicipis table.

## Overview

The `RiderPositionService` class provides methods to retrieve coordinates for riders based on their municipi field, which maps to the name field in the geolocatmunicipis table.

## Files Created

1. **app/services/rider_position_service.rb** - Main service class
2. **scripts/get_rider_position.rb** - Command-line script for testing
3. **test_rider_position.rb** - Test script for verification

## Usage

### 1. Using the Service Class

```ruby
# Get position for a user object
user = User.find(1)
position = RiderPositionService.get_position(user)
# Returns: { x: 123.45, y: 678.90, municipi: "Barcelona" }

# Get position by user ID
position = RiderPositionService.get_position_by_id(1)

# Get position by municipi name
position = RiderPositionService.get_position_by_municipi("Barcelona")

# Get all rider positions
positions = RiderPositionService.get_all_rider_positions
# Returns array of hashes with user info and coordinates
```

### 2. Using the Command Line Script

```bash
# Get position for specific user
ruby scripts/get_rider_position.rb --user-id 1

# Get position for specific municipi
ruby scripts/get_rider_position.rb --municipi "Barcelona"

# Get all rider positions
ruby scripts/get_rider_position.rb --all

# Show help
ruby scripts/get_rider_position.rb --help
```

## Database Schema

The service expects the following tables:

### geolocatmunicipis table
- `name` (string) - Municipi name (matches User.municipi)
- `x` (decimal/float) - Longitude coordinate
- `y` (decimal/float) - Latitude coordinate

### users table
- `municipi` (string) - User's municipi (matches geolocatmunicipis.name)

## Integration with Existing Code

The existing `MapsController` already uses similar functionality in the `riders` action:

```ruby
# Current implementation in MapsController
User.joins("INNER JOIN geolocatmunicipis ON users.municipi = geolocatmunicipis.name")
    .select('users.*, geolocatmunicipis.x AS longitude, geolocatmunicipis.y AS latitude')
```

## Error Handling

The service handles the following cases:
- Missing user object
- User without municipi
- Municipi not found in geolocatmunicipis table
- Database connection issues

All methods return `nil` when data is not found, making them safe to use in production.

## Testing

Run the test script to verify functionality:

```bash
ruby test_rider_position.rb
```

## Rails Console Usage

You can also use the service directly in Rails console:

```ruby
# Start Rails console
rails console

# Test the service
user = User.first
RiderPositionService.get_position(user)
```

## Notes

- The service uses the exact table name `geolocatmunicipis` as specified in the requirements
- Coordinates are returned as a hash with `:x` and `:y` keys
- The service is designed to be lightweight and efficient
- All database queries use proper joins to ensure data integrity
