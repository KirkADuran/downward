(define (problem zenotravel-ipc-008-inverse)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 city3 city4 - city
    plane1 plane2 plane3 - aircraft
    person1 person2 person3 person4 person5 person6 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 6)
    (= (person-cost person2) 5)
    (= (person-cost person3) 4)
    (= (person-cost person4) 3)
    (= (person-cost person5) 2)
    (= (person-cost person6) 1)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city0)
    (at-aircraft plane2 city3)
    (at-aircraft plane3 city0)
    (at-person person1 city1)
    (at-person person2 city0)
    (at-person person3 city2)
    (at-person person4 city0)
    (at-person person5 city3)
    (at-person person6 city4)
  )

  (:goal
    (and
      (at-aircraft plane1 city3)
      (at-person person1 city0)
      (at-person person2 city0)
      (at-person person3 city1)
      (at-person person4 city0)
      (at-person person5 city3)
      (at-person person6 city2)
    )
  )

  (:metric minimize (total-cost))
)
