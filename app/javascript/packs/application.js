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
import "./navbar_offset";
import "./repairs";
import "./defects";
import "./spare_parts";
import "./mods";
import "./shapes_decor";

import { application } from "controllers"
import CatalogPickerController from "../controllers/catalog_picker_controller"

window.bootstrap = bootstrap
window.jQuery = $;
window.$ = $;
global.toastr = require("toastr")

Rails.start()
ActiveStorage.start()

application.register("catalog-picker", CatalogPickerController)
window.Stimulus = application

export default application
