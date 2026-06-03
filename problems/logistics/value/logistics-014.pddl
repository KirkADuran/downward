(define (problem logistics-ipc-014-value)
  (:domain logistics)

  (:objects
    cit1 cit2 cit3 - city
    apt1 apt2 apt3 pos1 pos2 pos3 - location
    tru1 tru2 tru3 - truck
    apn1 - airplane
    obj11 obj12 obj13 obj21 obj22 obj23 obj31 obj32 obj33 - package
  )

  (:init
    (= (total-cost) 0)
    (= (package-cost obj11) 1)
    (= (package-cost obj12) 2)
    (= (package-cost obj13) 3)
    (= (package-cost obj21) 4)
    (= (package-cost obj22) 5)
    (= (package-cost obj23) 6)
    (= (package-cost obj31) 7)
    (= (package-cost obj32) 8)
    (= (package-cost obj33) 9)
    (= (drive-cost) 1)
    (= (fly-cost) 1)
    (at apn1 apt3)
    (at tru1 pos1)
    (at-package obj11 pos1)
    (at-package obj12 pos1)
    (at-package obj13 pos1)
    (at tru2 pos2)
    (at-package obj21 pos2)
    (at-package obj22 pos2)
    (at-package obj23 pos2)
    (at tru3 pos3)
    (at-package obj31 pos3)
    (at-package obj32 pos3)
    (at-package obj33 pos3)
    (in-city pos1 cit1)
    (in-city apt1 cit1)
    (in-city pos2 cit2)
    (in-city apt2 cit2)
    (in-city pos3 cit3)
    (in-city apt3 cit3)
  )

  (:goal
    (and
      (at-package obj22 pos3)
      (at-package obj13 pos2)
      (at-package obj32 apt2)
      (at-package obj33 apt3)
      (at-package obj23 apt2)
      (at-package obj31 apt1)
      (at-package obj21 pos3)
      (at-package obj12 pos3)
    )
  )

  (:metric minimize (total-cost))
)
