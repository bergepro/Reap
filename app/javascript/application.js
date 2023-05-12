// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "./src/jquery"

import { Application } from "@hotwired/stimulus"

import ModalController from "./controllers/modal_controller"

const application = Application.start()

application.register("modal", ModalController)
