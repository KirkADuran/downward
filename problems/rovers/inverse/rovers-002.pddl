(define (problem rovers-ipc-002-inverse)
  (:domain rovers)

  (:objects
    rover0 - rover
    waypoint0 waypoint1 waypoint2 waypoint3 - waypoint
    rover0store - store
    camera0 camera1 - camera
    colour high_res low_res - mode
    objective0 objective1 - objective
    general - lander
  )

  (:init
    (= (total-cost) 0)
    (= (sample-cost waypoint0) 4)
    (= (sample-cost waypoint1) 3)
    (= (sample-cost waypoint2) 2)
    (= (sample-cost waypoint3) 1)
    (= (image-cost objective0) 2)
    (= (image-cost objective1) 1)
    (= (rover-cost rover0) 1)
    (= (communicate-cost) 1)
    (visible waypoint0 waypoint1)
    (visible waypoint1 waypoint0)
    (visible waypoint1 waypoint2)
    (visible waypoint2 waypoint1)
    (visible waypoint1 waypoint3)
    (visible waypoint3 waypoint1)
    (visible waypoint2 waypoint0)
    (visible waypoint0 waypoint2)
    (visible waypoint2 waypoint3)
    (visible waypoint3 waypoint2)
    (visible waypoint3 waypoint0)
    (visible waypoint0 waypoint3)
    (at-lander general waypoint1)
    (channel-free general)
    (at rover0 waypoint0)
    (store-of rover0store rover0)
    (empty rover0store)
    (equipped-for-soil-analysis rover0)
    (equipped-for-rock-analysis rover0)
    (equipped-for-imaging rover0)
    (can-traverse rover0 waypoint0 waypoint1)
    (can-traverse rover0 waypoint1 waypoint0)
    (can-traverse rover0 waypoint0 waypoint2)
    (can-traverse rover0 waypoint2 waypoint0)
    (can-traverse rover0 waypoint0 waypoint3)
    (can-traverse rover0 waypoint3 waypoint0)
    (on-board camera0 rover0)
    (calibration-target camera0 objective0)
    (supports camera0 colour)
    (supports camera0 high_res)
    (supports camera0 low_res)
    (on-board camera1 rover0)
    (calibration-target camera1 objective1)
    (supports camera1 high_res)
    (visible-from objective0 waypoint0)
    (visible-from objective1 waypoint0)
    (visible-from objective1 waypoint1)
    (visible-from objective1 waypoint2)
  )

  (:goal
    (and
      (communicated-soil-data waypoint0)
      (communicated-rock-data waypoint0)
      (communicated-image-data objective1 low_res)
    )
  )

  (:metric minimize (total-cost))
)
