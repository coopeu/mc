if Rails.env.development?
  require 'rack-mini-profiler'

  # Configure Mini Profiler
  Rack::MiniProfiler.config.position = 'bottom-right'
  Rack::MiniProfiler.config.start_hidden = true
  Rack::MiniProfiler.config.toggle_shortcut = 'Alt+P'
  
  # Enable advanced features
  Rack::MiniProfiler.config.enable_advanced_debugging_tools = true
  
  # Configure storage
  Rack::MiniProfiler.config.storage_options = { path: Rails.root.join('tmp/mini-profiler') }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::FileStore
  
  # Configure authorization
  Rack::MiniProfiler.config.authorization_mode = :allow_all
end 