(define (problem logistics-ipc-029-unit)
  (:domain logistics)

  (:objects
    city1 city2 city3 city4 city5 city6 - city
    city1-1 city1-2 city2-1 city2-2 city3-1 city3-2 city4-1 city4-2 city5-1 city5-2 city6-1 city6-2 - location
    truck1 truck2 truck3 truck4 truck5 truck6 - truck
    plane1 plane2 - airplane
    package1 package2 package3 package4 package5 package6 - package
  )

  (:init
    (= (total-cost) 0)
    (= (package-cost package1) 1)
    (= (package-cost package2) 1)
    (= (package-cost package3) 1)
    (= (package-cost package4) 1)
    (= (package-cost package5) 1)
    (= (package-cost package6) 1)
    (= (drive-cost) 1)
    (= (fly-cost) 1)
    (in-city city6-2 city6)
    (in-city city6-1 city6)
    (in-city city5-2 city5)
    (in-city city5-1 city5)
    (in-city city4-2 city4)
    (in-city city4-1 city4)
    (in-city city3-2 city3)
    (in-city city3-1 city3)
    (in-city city2-2 city2)
    (in-city city2-1 city2)
    (in-city city1-2 city1)
    (in-city city1-1 city1)
    (at plane2 city4-2)
    (at plane1 city4-2)
    (at truck6 city6-1)
    (at truck5 city5-1)
    (at truck4 city4-1)
    (at truck3 city3-1)
    (at truck2 city2-1)
    (at truck1 city1-1)
    (at-package package6 city3-1)
    (at-package package5 city4-2)
    (at-package package4 city1-1)
    (at-package package3 city1-1)
    (at-package package2 city1-2)
    (at-package package1 city2-1)
  )

  (:goal
    (and
      (at-package package6 city1-2)
      (at-package package5 city6-2)
      (at-package package4 city3-2)
      (at-package package3 city6-1)
      (at-package package2 city6-2)
      (at-package package1 city2-1)
    )
  )

  (:metric minimize (total-cost))
)
