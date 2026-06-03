(define (problem depots-ipc-003-value)
  (:domain depots)

  (:objects
    depot0 distributor0 distributor1 - place
    truck0 truck1 - truck
    hoist0 hoist1 hoist2 - hoist
    pallet0 pallet1 pallet2 - surface
    crate0 crate1 crate2 crate3 crate4 crate5 - crate
  )

  (:init
    (= (total-cost) 0)
    (= (crate-cost crate0) 1)
    (= (crate-cost crate1) 2)
    (= (crate-cost crate2) 3)
    (= (crate-cost crate3) 4)
    (= (crate-cost crate4) 5)
    (= (crate-cost crate5) 6)
    (= (drive-cost) 1)
    (clear crate1)
    (clear crate4)
    (clear crate5)
    (at-truck truck0 depot0)
    (at-truck truck1 distributor0)
    (at-hoist hoist0 depot0)
    (available hoist0)
    (at-hoist hoist1 distributor0)
    (available hoist1)
    (at-hoist hoist2 distributor1)
    (available hoist2)
    (at-crate crate0 distributor0)
    (on crate0 pallet1)
    (at-crate crate1 depot0)
    (on crate1 pallet0)
    (at-crate crate2 distributor1)
    (on crate2 pallet2)
    (at-crate crate3 distributor0)
    (on crate3 crate0)
    (at-crate crate4 distributor0)
    (on crate4 crate3)
    (at-crate crate5 distributor1)
    (on crate5 crate2)
  )

  (:goal
    (and
      (on crate0 crate1)
      (on crate1 pallet2)
      (on crate2 pallet0)
      (on crate3 crate2)
      (on crate4 pallet1)
      (on crate5 crate0)
    )
  )

  (:metric minimize (total-cost))
)
