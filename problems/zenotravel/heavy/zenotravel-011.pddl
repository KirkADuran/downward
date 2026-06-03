(define (problem zenotravel-ipc-011-heavy)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 city3 city4 city5 - city
    plane1 plane2 plane3 - aircraft
    person1 person2 person3 person4 person5 person6 person7 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 1)
    (= (person-cost person2) 1)
    (= (person-cost person3) 1)
    (= (person-cost person4) 1)
    (= (person-cost person5) 1)
    (= (person-cost person6) 10)
    (= (person-cost person7) 10)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city4)
    (at-aircraft plane2 city4)
    (at-aircraft plane3 city1)
    (at-person person1 city4)
    (at-person person2 city2)
    (at-person person3 city2)
    (at-person person4 city0)
    (at-person person5 city2)
    (at-person person6 city2)
    (at-person person7 city5)
  )

  (:goal
    (and
      (at-aircraft plane1 city1)
      (at-person person1 city4)
      (at-person person2 city1)
      (at-person person3 city2)
      (at-person person4 city2)
      (at-person person5 city2)
      (at-person person6 city4)
      (at-person person7 city0)
    )
  )

  (:metric minimize (total-cost))
)
