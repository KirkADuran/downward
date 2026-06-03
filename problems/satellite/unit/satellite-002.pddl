(define (problem satellite-ipc-002-unit)
  (:domain satellite)

  (:objects
    satellite0 - satellite
    instrument0 instrument1 - instrument
    image2 infrared0 infrared1 - mode
    groundstation1 groundstation2 phenomenon5 phenomenon6 planet3 planet4 star0 star7 - direction
  )

  (:init
    (= (total-cost) 0)
    (= (target-cost groundstation1) 1)
    (= (target-cost groundstation2) 1)
    (= (target-cost phenomenon5) 1)
    (= (target-cost phenomenon6) 1)
    (= (target-cost planet3) 1)
    (= (target-cost planet4) 1)
    (= (target-cost star0) 1)
    (= (target-cost star7) 1)
    (= (instrument-cost instrument0) 1)
    (= (instrument-cost instrument1) 1)
    (= (satellite-move-cost satellite0) 1)
    (supports instrument0 infrared1)
    (supports instrument0 infrared0)
    (calibration-target instrument0 star0)
    (supports instrument1 image2)
    (supports instrument1 infrared1)
    (supports instrument1 infrared0)
    (calibration-target instrument1 groundstation2)
    (on-board instrument0 satellite0)
    (on-board instrument1 satellite0)
    (power-avail satellite0)
    (pointing satellite0 planet4)
  )

  (:goal
    (and
      (have-image planet3 infrared0)
      (have-image planet4 infrared0)
      (have-image phenomenon5 image2)
      (have-image phenomenon6 infrared0)
      (have-image star7 infrared0)
    )
  )

  (:metric minimize (total-cost))
)
