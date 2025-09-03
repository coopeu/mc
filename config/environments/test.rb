Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false

  # Do not load or maintain the DB schema for tests that don't need DB
  if config.respond_to?(:active_record)
    config.active_record.maintain_test_schema = false
  end

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=3600"
  }

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr

  # Active Storage
  config.active_storage.service = :test
end


