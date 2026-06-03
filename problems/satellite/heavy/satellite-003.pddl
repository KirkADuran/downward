(define (problem satellite-ipc-003-heavy)
  (:domain satellite)

  (:objects
    satellite0 satellite1 - satellite
    instrument0 instrument1 instrument2 instrument3 - instrument
    image1 infrared0 spectrograph2 - mode
    phenomenon5 phenomenon6 phenomenon7 star0 star1 star2 star3 star4 - direction
  )

  (:init
    (= (total-cost) 0)
    (= (target-cost phenomenon5) 1)
    (= (target-cost phenomenon6) 1)
    (= (target-cost phenomenon7) 1)
    (= (target-cost star0) 1)
    (= (target-cost star1) 1)
    (= (target-cost star2) 1)
    (= (target-cost star3) 10)
    (= (target-cost star4) 10)
    (= (instrument-cost instrument0) 1)
    (= (instrument-cost instrument1) 1)
    (= (instrument-cost instrument2) 1)
    (= (instrument-cost instrument3) 10)
    (= (satellite-move-cost satellite0) 1)
    (= (satellite-move-cost satellite1) 10)
    (supports instrument0 spectrograph2)
    (supports instrument0 infrared0)
    (calibration-target instrument0 star1)
    (supports instrument1 image1)
    (calibration-target instrument1 star2)
    (supports instrument2 infrared0)
    (supports instrument2 image1)
    (calibration-target instrument2 star0)
    (on-board instrument0 satellite0)
    (on-board instrument1 satellite0)
    (on-board instrument2 satellite0)
    (power-avail satellite0)
    (pointing satellite0 star4)
    (supports instrument3 spectrograph2)
    (supports instrument3 infrared0)
    (supports instrument3 image1)
    (calibration-target instrument3 star0)
    (on-board instrument3 satellite1)
    (power-avail satellite1)
    (pointing satellite1 star0)
  )

  (:goal
    (and
      (pointing satellite0 phenomenon5)
      (have-image star3 infrared0)
      (have-image star4 spectrograph2)
      (have-image phenomenon5 spectrograph2)
      (have-image phenomenon7 spectrograph2)
    )
  )

  (:metric minimize (total-cost))
)
