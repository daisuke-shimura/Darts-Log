// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import ResultController from "./result_controller"
import TargetController from "./target_controller"
import HoleController from "./board-logic/hole_controller"
import ZeroOneController from "./board-logic/zero-one_controller"
import CricketController from "./board-logic/cricket_controller"
import CountUpController from "./board-logic/count-up_controller"
application.register("result", ResultController)
application.register("target", TargetController)
application.register("hole", HoleController)
application.register("zero-one", ZeroOneController)
application.register("cricket", CricketController)
application.register("count-up", CountUpController)
