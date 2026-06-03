(define (problem miconic-ipc-007-heavy)
  (:domain miconic)

  (:objects
    f0 f1 f2 f3 - floor
    p0 p1 - passenger
  )

  (:init
    (= (total-cost) 0)
    (= (passenger-cost p0) 1)
    (= (passenger-cost p1) 10)
    (= (move-cost) 1)
    (above f1 f0)
    (above f2 f0)
    (above f3 f0)
    (above f2 f1)
    (above f3 f1)
    (above f3 f2)
    (origin p0 f0)
    (destin p0 f1)
    (origin p1 f3)
    (destin p1 f0)
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
