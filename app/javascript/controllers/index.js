// ✅ корректный вариант для Webpacker
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// Стартуем Stimulus
const application = Application.start()

// Автоподхват всех контроллеров из папки controllers
const context = require.context("controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

// Ручная регистрация наших контроллеров (если они не автоподхватились)
import DetailsController from "./details_controller"
import ModalOpenerController from "./modal_opener_controller"

application.register("details", DetailsController)
application.register("modal-opener", ModalOpenerController)

import ProductsFormController from "./products_form_controller"
application.register("products-form", ProductsFormController)

// (опционально) экспорт, если где-то нужен доступ
export { application }
