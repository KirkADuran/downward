(define (problem zenotravel-ipc-010-inverse)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 city3 city4 - city
    plane1 plane2 plane3 - aircraft
    person1 person2 person3 person4 person5 person6 person7 person8 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 8)
    (= (person-cost person2) 7)
    (= (person-cost person3) 6)
    (= (person-cost person4) 5)
    (= (person-cost person5) 4)
    (= (person-cost person6) 3)
    (= (person-cost person7) 2)
    (= (person-cost person8) 1)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city0)
    (at-aircraft plane2 city4)
    (at-aircraft plane3 city2)
    (at-person person1 city3)
    (at-person person2 city3)
    (at-person person3 city4)
    (at-person person4 city4)
    (at-person person5 city1)
    (at-person person6 city0)
    (at-person person7 city1)
    (at-person person8 city0)
  )

  (:goal
    (and
      (at-aircraft plane1 city2)
      (at-person person1 city1)
      (at-person person2 city2)
      (at-person person3 city3)
      (at-person person4 city1)
      (at-person person5 city0)
      (at-person person6 city3)
      (at-person person7 city4)
      (at-person person8 city3)
    )
  )

  (:metric minimize (total-cost))
)
