import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import * as bootstrap from "bootstrap"
import "channels"
import "../packs/application.scss"
import "@fortawesome/fontawesome-free/css/all.css"
import "trix"
import "@rails/actiontext"
import "moment"
import "daterangepicker"
import "@hotwired/turbo-rails"
import "controllers";
import "./store_nav";

window.bootstrap = bootstrap
window.jQuery = $;
window.$ = $;
global.toastr = require("toastr")

Rails.start()
ActiveStorage.start()
