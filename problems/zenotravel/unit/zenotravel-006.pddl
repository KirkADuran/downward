(define (problem zenotravel-ipc-006-unit)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 city3 - city
    plane1 plane2 - aircraft
    person1 person2 person3 person4 person5 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 1)
    (= (person-cost person2) 1)
    (= (person-cost person3) 1)
    (= (person-cost person4) 1)
    (= (person-cost person5) 1)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city2)
    (at-aircraft plane2 city1)
    (at-person person1 city0)
    (at-person person2 city0)
    (at-person person3 city3)
    (at-person person4 city1)
    (at-person person5 city2)
  )

  (:goal
    (and
      (at-person person1 city3)
      (at-person person2 city1)
      (at-person person3 city3)
      (at-person person4 city3)
      (at-person person5 city1)
    )
  )

  (:metric minimize (total-cost))
)
