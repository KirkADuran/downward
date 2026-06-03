(define (problem satellite-ipc-004-unit)
  (:domain satellite)

  (:objects
    satellite0 satellite1 - satellite
    instrument0 instrument1 instrument2 - instrument
    infrared0 infrared1 thermograph2 - mode
    groundstation1 phenomenon8 phenomenon9 planet3 planet5 star0 star2 star4 star6 star7 - direction
  )

  (:init
    (= (total-cost) 0)
    (= (target-cost groundstation1) 1)
    (= (target-cost phenomenon8) 1)
    (= (target-cost phenomenon9) 1)
    (= (target-cost planet3) 1)
    (= (target-cost planet5) 1)
    (= (target-cost star0) 1)
    (= (target-cost star2) 1)
    (= (target-cost star4) 1)
    (= (target-cost star6) 1)
    (= (target-cost star7) 1)
    (= (instrument-cost instrument0) 1)
    (= (instrument-cost instrument1) 1)
    (= (instrument-cost instrument2) 1)
    (= (satellite-move-cost satellite0) 1)
    (= (satellite-move-cost satellite1) 1)
    (supports instrument0 thermograph2)
    (supports instrument0 infrared0)
    (calibration-target instrument0 star0)
    (on-board instrument0 satellite0)
    (power-avail satellite0)
    (pointing satellite0 star6)
    (supports instrument1 infrared0)
    (supports instrument1 thermograph2)
    (supports instrument1 infrared1)
    (calibration-target instrument1 star2)
    (supports instrument2 thermograph2)
    (supports instrument2 infrared1)
    (calibration-target instrument2 star2)
    (on-board instrument1 satellite1)
    (on-board instrument2 satellite1)
    (power-avail satellite1)
    (pointing satellite1 star0)
  )

  (:goal
    (and
      (pointing satellite1 planet5)
      (have-image planet3 infrared1)
      (have-image star4 infrared1)
      (have-image planet5 thermograph2)
      (have-image star6 infrared1)
      (have-image star7 infrared0)
      (have-image phenomenon8 thermograph2)
      (have-image phenomenon9 infrared0)
    )
  )

  (:metric minimize (total-cost))
)
