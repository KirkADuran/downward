(define (problem zenotravel-ipc-009-inverse)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 city3 city4 - city
    plane1 plane2 plane3 - aircraft
    person1 person2 person3 person4 person5 person6 person7 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 7)
    (= (person-cost person2) 6)
    (= (person-cost person3) 5)
    (= (person-cost person4) 4)
    (= (person-cost person5) 3)
    (= (person-cost person6) 2)
    (= (person-cost person7) 1)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city2)
    (at-aircraft plane2 city2)
    (at-aircraft plane3 city1)
    (at-person person1 city4)
    (at-person person2 city1)
    (at-person person3 city2)
    (at-person person4 city0)
    (at-person person5 city4)
    (at-person person6 city3)
    (at-person person7 city3)
  )

  (:goal
    (and
      (at-person person1 city2)
      (at-person person2 city0)
      (at-person person3 city4)
      (at-person person4 city3)
      (at-person person5 city1)
      (at-person person6 city4)
      (at-person person7 city4)
    )
  )

  (:metric minimize (total-cost))
)
