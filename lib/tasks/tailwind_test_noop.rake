# frozen_string_literal: true

# Skip Tailwind CSS build during test runs to avoid CSS build failures
if ENV['RAILS_ENV'] == 'test'
  Rake::Task['tailwindcss:build'].clear if Rake::Task.task_defined?('tailwindcss:build')

  task 'tailwindcss:build' => :environment do
    # no-op in test
  end
end
