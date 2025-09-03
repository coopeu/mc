  // Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// app/javascript/application.js
import "controllers"

import "trix"
import "@rails/actiontext"

import 'flowbite'
//import 'flowbite-datepicker'
//import 'flowbite/dist/datepicker.turbo.js'

import "./channels"

//import { Collapse, Dropdown, initTWE } from "tw-elements";
//initTWE({ Collapse, Dropdown });

// Import Rails UJS
import Rails from "@rails/ujs"
Rails.start()