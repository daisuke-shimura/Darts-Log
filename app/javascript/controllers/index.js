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
import CenterCountUpController from "./board-logic/center_count_up_controller"
import CricketCountUpController from "./board-logic/cricket_count_up_controller"
import ShootOutController from "./board-logic/shoot_out_controller"
application.register("result", ResultController)
application.register("target", TargetController)
application.register("hole", HoleController)
application.register("zero-one", ZeroOneController)
application.register("cricket", CricketController)
application.register("count-up", CountUpController)
application.register("center-count-up", CenterCountUpController)
application.register("cricket-count-up", CricketCountUpController)
application.register("shoot-out", ShootOutController)
