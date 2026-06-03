(define (problem satellite-ipc-001-value)
  (:domain satellite)

  (:objects
    satellite0 - satellite
    instrument0 - instrument
    image1 spectrograph2 thermograph0 - mode
    groundstation1 groundstation2 phenomenon3 phenomenon4 phenomenon6 star0 star5 - direction
  )

  (:init
    (= (total-cost) 0)
    (= (target-cost groundstation1) 1)
    (= (target-cost groundstation2) 2)
    (= (target-cost phenomenon3) 3)
    (= (target-cost phenomenon4) 4)
    (= (target-cost phenomenon6) 5)
    (= (target-cost star0) 6)
    (= (target-cost star5) 7)
    (= (instrument-cost instrument0) 1)
    (= (satellite-move-cost satellite0) 1)
    (supports instrument0 thermograph0)
    (calibration-target instrument0 groundstation2)
    (on-board instrument0 satellite0)
    (power-avail satellite0)
    (pointing satellite0 phenomenon6)
  )

  (:goal
    (and
      (have-image phenomenon4 thermograph0)
      (have-image star5 thermograph0)
      (have-image phenomenon6 thermograph0)
    )
  )

  (:metric minimize (total-cost))
)
