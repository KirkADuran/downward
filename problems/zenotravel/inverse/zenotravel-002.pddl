(define (problem zenotravel-ipc-002-inverse)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 - city
    plane1 - aircraft
    person1 person2 person3 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 3)
    (= (person-cost person2) 2)
    (= (person-cost person3) 1)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city0)
    (at-person person1 city2)
    (at-person person2 city1)
    (at-person person3 city2)
  )

  (:goal
    (and
      (at-aircraft plane1 city2)
      (at-person person1 city1)
      (at-person person3 city2)
    )
  )

  (:metric minimize (total-cost))
)
