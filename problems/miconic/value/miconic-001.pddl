(define (problem miconic-ipc-001-value)
  (:domain miconic)

  (:objects
    f0 f1 - floor
    p0 - passenger
  )

  (:init
    (= (total-cost) 0)
    (= (passenger-cost p0) 1)
    (= (move-cost) 1)
    (above f1 f0)
    (origin p0 f1)
    (destin p0 f0)
    (lift-at f0)
  )

  (:goal
    (and
      (served p0)
    )
  )

  (:metric minimize (total-cost))
)
