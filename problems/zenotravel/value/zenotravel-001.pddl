(define (problem zenotravel-ipc-001-value)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 - city
    plane1 - aircraft
    person1 person2 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 1)
    (= (person-cost person2) 2)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city0)
    (at-person person1 city0)
    (at-person person2 city2)
  )

  (:goal
    (and
      (at-aircraft plane1 city1)
      (at-person person1 city0)
      (at-person person2 city2)
    )
  )

  (:metric minimize (total-cost))
)
