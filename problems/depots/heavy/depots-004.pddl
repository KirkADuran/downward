(define (problem depots-ipc-004-heavy)
  (:domain depots)

  (:objects
    depot0 distributor0 distributor1 - place
    truck0 truck1 - truck
    hoist0 hoist1 hoist2 - hoist
    pallet0 pallet1 pallet2 - surface
    crate0 crate1 crate2 crate3 crate4 crate5 crate6 crate7 - crate
  )

  (:init
    (= (total-cost) 0)
    (= (crate-cost crate0) 1)
    (= (crate-cost crate1) 1)
    (= (crate-cost crate2) 1)
    (= (crate-cost crate3) 1)
    (= (crate-cost crate4) 1)
    (= (crate-cost crate5) 1)
    (= (crate-cost crate6) 10)
    (= (crate-cost crate7) 10)
    (= (drive-cost) 1)
    (clear crate7)
    (clear crate2)
    (clear crate6)
    (at-truck truck0 distributor1)
    (at-truck truck1 distributor1)
    (at-hoist hoist0 depot0)
    (available hoist0)
    (at-hoist hoist1 distributor0)
    (available hoist1)
    (at-hoist hoist2 distributor1)
    (available hoist2)
    (at-crate crate0 depot0)
    (on crate0 pallet0)
    (at-crate crate1 depot0)
    (on crate1 crate0)
    (at-crate crate2 distributor0)
    (on crate2 pallet1)
    (at-crate crate3 distributor1)
    (on crate3 pallet2)
    (at-crate crate4 depot0)
    (on crate4 crate1)
    (at-crate crate5 distributor1)
    (on crate5 crate3)
    (at-crate crate6 distributor1)
    (on crate6 crate5)
    (at-crate crate7 depot0)
    (on crate7 crate4)
  )

  (:goal
    (and
      (on crate0 crate4)
      (on crate2 crate6)
      (on crate4 crate7)
      (on crate5 pallet2)
      (on crate6 pallet1)
      (on crate7 pallet0)
    )
  )

  (:metric minimize (total-cost))
)
