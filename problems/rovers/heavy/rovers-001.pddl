(define (problem rovers-ipc-001-heavy)
  (:domain rovers)

  (:objects
    rover0 - rover
    waypoint0 waypoint1 waypoint2 waypoint3 - waypoint
    rover0store - store
    camera0 - camera
    colour high_res low_res - mode
    objective0 objective1 - objective
    general - lander
  )

  (:init
    (= (total-cost) 0)
    (= (sample-cost waypoint0) 1)
    (= (sample-cost waypoint1) 1)
    (= (sample-cost waypoint2) 1)
    (= (sample-cost waypoint3) 10)
    (= (image-cost objective0) 1)
    (= (image-cost objective1) 10)
    (= (rover-cost rover0) 10)
    (= (communicate-cost) 1)
    (visible waypoint1 waypoint0)
    (visible waypoint0 waypoint1)
    (visible waypoint2 waypoint0)
    (visible waypoint0 waypoint2)
    (visible waypoint2 waypoint1)
    (visible waypoint1 waypoint2)
    (visible waypoint3 waypoint0)
    (visible waypoint0 waypoint3)
    (visible waypoint3 waypoint1)
    (visible waypoint1 waypoint3)
    (visible waypoint3 waypoint2)
    (visible waypoint2 waypoint3)
    (at-lander general waypoint0)
    (channel-free general)
    (at rover0 waypoint3)
    (store-of rover0store rover0)
    (empty rover0store)
    (equipped-for-soil-analysis rover0)
    (equipped-for-rock-analysis rover0)
    (equipped-for-imaging rover0)
    (can-traverse rover0 waypoint3 waypoint0)
    (can-traverse rover0 waypoint0 waypoint3)
    (can-traverse rover0 waypoint3 waypoint1)
    (can-traverse rover0 waypoint1 waypoint3)
    (can-traverse rover0 waypoint1 waypoint2)
    (can-traverse rover0 waypoint2 waypoint1)
    (on-board camera0 rover0)
    (calibration-target camera0 objective1)
    (supports camera0 colour)
    (supports camera0 high_res)
    (visible-from objective0 waypoint0)
    (visible-from objective0 waypoint1)
    (visible-from objective0 waypoint2)
    (visible-from objective0 waypoint3)
    (visible-from objective1 waypoint0)
    (visible-from objective1 waypoint1)
    (visible-from objective1 waypoint2)
    (visible-from objective1 waypoint3)
  )

  (:goal
    (and
      (communicated-soil-data waypoint2)
      (communicated-rock-data waypoint3)
      (communicated-image-data objective1 high_res)
    )
  )

  (:metric minimize (total-cost))
)
