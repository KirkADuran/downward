(define (problem zenotravel-ipc-014-value)
  (:domain zenotravel)

  (:objects
    city0 city1 city2 city3 city4 city5 city6 city7 city8 city9 - city
    plane1 plane2 plane3 plane4 plane5 - aircraft
    person1 person2 person3 person4 person5 person6 person7 person8 person9 person10 - person
  )

  (:init
    (= (total-cost) 0)
    (= (person-cost person1) 1)
    (= (person-cost person2) 2)
    (= (person-cost person3) 3)
    (= (person-cost person4) 4)
    (= (person-cost person5) 5)
    (= (person-cost person6) 6)
    (= (person-cost person7) 7)
    (= (person-cost person8) 8)
    (= (person-cost person9) 9)
    (= (person-cost person10) 10)
    (= (fly-cost) 1)
    (= (zoom-cost) 1)
    (at-aircraft plane1 city5)
    (at-aircraft plane2 city2)
    (at-aircraft plane3 city4)
    (at-aircraft plane4 city8)
    (at-aircraft plane5 city9)
    (at-person person1 city9)
    (at-person person2 city1)
    (at-person person3 city0)
    (at-person person4 city9)
    (at-person person5 city6)
    (at-person person6 city0)
    (at-person person7 city7)
    (at-person person8 city6)
    (at-person person9 city4)
    (at-person person10 city7)
  )

  (:goal
    (and
      (at-aircraft plane2 city3)
      (at-aircraft plane4 city5)
      (at-aircraft plane5 city8)
      (at-person person2 city8)
      (at-person person3 city2)
      (at-person person4 city7)
      (at-person person5 city1)
      (at-person person6 city6)
      (at-person person7 city5)
      (at-person person8 city1)
      (at-person person9 city5)
      (at-person person10 city9)
    )
  )

  (:metric minimize (total-cost))
)
