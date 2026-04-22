// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import HoleController from "./hole_controller"
import ResultController from "./result_controller"
import TargetController from "./target_controller"
application.register("hole", HoleController)
application.register("result", ResultController)
application.register("target", TargetController)