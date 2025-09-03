# frozen_string_literal: true

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.esm.js'
pin '@rails/request.js', to: '@rails--request.js.js' # @0.0.9

pin '@rails/actioncable', to: 'actioncable.esm.js'
pin '@rails/activestorage', to: 'activestorage.esm.js'

pin 'flowbite', to: 'https://cdn.jsdelivr.net/npm/flowbite@2.5.1/dist/flowbite.turbo.min.js'
pin_all_from 'app/javascript/channels', under: 'channels'
