(define (problem logistics-ipc-002-inverse)
  (:domain logistics)

  (:objects
    cit1 cit2 - city
    apt1 apt2 pos1 pos2 - location
    tru1 tru2 - truck
    apn1 - airplane
    obj11 obj12 obj13 obj21 obj22 obj23 - package
  )

  (:init
    (= (total-cost) 0)
    (= (package-cost obj11) 6)
    (= (package-cost obj12) 5)
    (= (package-cost obj13) 4)
    (= (package-cost obj21) 3)
    (= (package-cost obj22) 2)
    (= (package-cost obj23) 1)
    (= (drive-cost) 1)
    (= (fly-cost) 1)
    (at apn1 apt2)
    (at tru1 pos1)
    (at-package obj11 pos1)
    (at-package obj12 pos1)
    (at-package obj13 pos1)
    (at tru2 pos2)
    (at-package obj21 pos2)
    (at-package obj22 pos2)
    (at-package obj23 pos2)
    (in-city pos1 cit1)
    (in-city apt1 cit1)
    (in-city pos2 cit2)
    (in-city apt2 cit2)
  )

  (:goal
    (and
      (at-package obj12 apt2)
      (at-package obj13 apt1)
      (at-package obj21 apt2)
      (at-package obj11 pos2)
    )
  )

  (:metric minimize (total-cost))
)
