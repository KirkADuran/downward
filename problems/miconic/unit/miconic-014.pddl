(define (problem miconic-ipc-014-unit)
  (:domain miconic)

  (:objects
    f0 f1 f2 f3 f4 f5 - floor
    p0 p1 p2 - passenger
  )

  (:init
    (= (total-cost) 0)
    (= (passenger-cost p0) 1)
    (= (passenger-cost p1) 1)
    (= (passenger-cost p2) 1)
    (= (move-cost) 1)
    (above f1 f0)
    (above f2 f0)
    (above f3 f0)
    (above f4 f0)
    (above f5 f0)
    (above f2 f1)
    (above f3 f1)
    (above f4 f1)
    (above f5 f1)
    (above f3 f2)
    (above f4 f2)
    (above f5 f2)
    (above f4 f3)
    (above f5 f3)
    (above f5 f4)
    (origin p0 f5)
    (destin p0 f0)
    (origin p1 f1)
    (destin p1 f3)
    (origin p2 f0)
    (destin p2 f5)
    (lift-at f0)
  )

  (:goal
    (and
      (served p0)
      (served p1)
      (served p2)
    )
  )

  (:metric minimize (total-cost))
)
