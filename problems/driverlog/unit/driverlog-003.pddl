(define (problem driverlog-ipc-003-unit)
  (:domain driverlog)

  (:objects
    p0-1 p2-0 p2-1 s0 s1 s2 - location
    truck1 truck2 - truck
    driver1 driver2 - driver
    package1 package2 package3 package4 - package
  )

  (:init
    (= (total-cost) 0)
    (= (package-cost package1) 1)
    (= (package-cost package2) 1)
    (= (package-cost package3) 1)
    (= (package-cost package4) 1)
    (= (driver-cost driver1) 1)
    (= (driver-cost driver2) 1)
    (= (drive-cost) 1)
    (= (walk-cost) 1)
    (at-driver driver1 s1)
    (at-driver driver2 s0)
    (at-truck truck1 s1)
    (empty truck1)
    (at-truck truck2 s2)
    (empty truck2)
    (at-package package1 s0)
    (at-package package2 s0)
    (at-package package3 s1)
    (at-package package4 s1)
    (path s0 p0-1)
    (path p0-1 s0)
    (path s1 p0-1)
    (path p0-1 s1)
    (path s2 p2-0)
    (path p2-0 s2)
    (path s0 p2-0)
    (path p2-0 s0)
    (path s2 p2-1)
    (path p2-1 s2)
    (path s1 p2-1)
    (path p2-1 s1)
    (link s1 s0)
    (link s0 s1)
    (link s1 s2)
    (link s2 s1)
    (link s2 s0)
    (link s0 s2)
  )

  (:goal
    (and
      (at-driver driver2 s2)
      (at-truck truck1 s1)
      (at-truck truck2 s2)
      (at-package package1 s1)
      (at-package package2 s1)
      (at-package package3 s2)
    )
  )

  (:metric minimize (total-cost))
)
