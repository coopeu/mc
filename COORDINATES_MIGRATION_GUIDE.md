# User Coordinates Migration Guide

This guide explains how to migrate user coordinates from the geolocatmunicipis table to the users table.

## Overview

The migration adds `latitude` and `longitude` columns to the users table and populates them with precise coordinates from the geolocatmunicipis table based on each user's municipi.

## Files Created

1. **Migration**: `db/migrate/20250830161800_add_coordinates_to_users.rb`
2. **Rake Tasks**: `lib/tasks/update_user_coordinates.rake`

## Step-by-Step Instructions

### 1. Run the Migration

```bash
# Run the migration to add columns and populate data
rails db:migrate
```

This will:
- Add `latitude` and `longitude` columns to users table
- Populate these columns with exact coordinates from geolocatmunicipis
- Show progress and statistics

### 2. Manual Coordinate Updates (Optional)

If you need to run the coordinate updates separately:

```bash
# Update coordinates for all users
rails users:update_coordinates

# Verify the updates
rails users:verify_coordinates

# Reset coordinates if needed
rails users:reset_coordinates
```

### 3. Database Connection

The migration uses your existing Rails database configuration. No additional credentials are needed as it uses the configured database connection.

### 4. Expected Results

After running the migration:
- Users table will have `latitude` and `longitude` columns
- Each user will have coordinates matching their municipi's position
- Users without a valid municipi will have NULL coordinates

### 5. Usage in Code

After migration, you can access user coordinates directly:

```ruby
# Get user coordinates
user = User.find(1)
puts "Latitude: #{user.latitude}, Longitude: #{user.longitude}"

# Find users near a location
User.where.not(latitude: nil, longitude: nil).near([lat, lng], 10)

# Update coordinates for a specific user
user.update_coordinates_from_municipi
```

### 6. Troubleshooting

#### If geolocatmunicipis table doesn't exist:
```bash
# Check if table exists
rails console
ActiveRecord::Base.connection.table_exists?('geolocatmunicipis')
```

#### If migration fails:
```bash
# Check migration status
rails db:migrate:status

# Rollback if needed
rails db:rollback
```

#### Manual verification:
```sql
-- Check the data
SELECT u.id, u.nom, u.municipi, u.latitude, u.longitude, g.x, g.y
FROM users u
INNER JOIN geolocatmunicipis g ON u.municipi = g.name
WHERE u.latitude IS NOT NULL;
```

### 7. Performance Notes

- The migration uses efficient SQL joins for bulk updates
- Processing time depends on the number of users
- The rake task provides progress indicators (`.` for success, `X` for skipped)

### 8. Security

- Uses Rails database configuration (no hardcoded credentials)
- Follows Rails migration best practices
- Safe for production use with proper backups

## Example Output

After running the migration, you should see:

```
== 20250830161800 AddCoordinatesToUsers: migrating ===========================
-- add_column(:users, :latitude, :decimal, {:precision=>10, :scale=>6})
   -> 0.0012s
-- add_column(:users, :longitude, :decimal, {:precision=>10, :scale=>6})
   -> 0.0010s
Updated 247 users with coordinates
== 20250830161800 AddCoordinatesToUsers: migrated (0.0456s) ==================
```

## Next Steps

1. Run the migration: `rails db:migrate`
2. Verify the data: `rails users:verify_coordinates`
3. Update your application code to use the new columns
4. Consider adding indexes for performance if querying by location
