(define (problem miconic-ipc-009-unit)
  (:domain miconic)

  (:objects
    f0 f1 f2 f3 - floor
    p0 p1 - passenger
  )

  (:init
    (= (total-cost) 0)
    (= (passenger-cost p0) 1)
    (= (passenger-cost p1) 1)
    (= (move-cost) 1)
    (above f1 f0)
    (above f2 f0)
    (above f3 f0)
    (above f2 f1)
    (above f3 f1)
    (above f3 f2)
    (origin p0 f1)
    (destin p0 f3)
    (origin p1 f2)
    (destin p1 f3)
    (lift-at f0)
  )

  (:goal
    (and
      (served p0)
      (served p1)
    )
  )

  (:metric minimize (total-cost))
)
