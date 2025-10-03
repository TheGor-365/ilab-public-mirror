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
import ProductsFormController from "./products_form_controller"
import FrameResetController from "./frame_reset_controller"

application.register("details", DetailsController)
application.register("modal-opener", ModalOpenerController)
application.register("products-form", ProductsFormController)
application.register("frame-reset", FrameResetController)

// (опционально) экспорт, если где-то нужен доступ
export { application }
