(define (problem driverlog-ipc-001-value)
  (:domain driverlog)

  (:objects
    p1-0 p1-2 s0 s1 s2 - location
    truck1 truck2 - truck
    driver1 driver2 - driver
    package1 package2 - package
  )

  (:init
    (= (total-cost) 0)
    (= (package-cost package1) 1)
    (= (package-cost package2) 2)
    (= (driver-cost driver1) 1)
    (= (driver-cost driver2) 2)
    (= (drive-cost) 1)
    (= (walk-cost) 1)
    (at-driver driver1 s2)
    (at-driver driver2 s2)
    (at-truck truck1 s0)
    (empty truck1)
    (at-truck truck2 s0)
    (empty truck2)
    (at-package package1 s0)
    (at-package package2 s0)
    (path s1 p1-0)
    (path p1-0 s1)
    (path s0 p1-0)
    (path p1-0 s0)
    (path s1 p1-2)
    (path p1-2 s1)
    (path s2 p1-2)
    (path p1-2 s2)
    (link s0 s1)
    (link s1 s0)
    (link s0 s2)
    (link s2 s0)
    (link s2 s1)
    (link s1 s2)
  )

  (:goal
    (and
      (at-driver driver1 s1)
      (at-truck truck1 s1)
      (at-package package1 s0)
      (at-package package2 s0)
    )
  )

  (:metric minimize (total-cost))
)
