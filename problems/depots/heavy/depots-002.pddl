(define (problem depots-ipc-002-heavy)
  (:domain depots)

  (:objects
    depot0 distributor0 distributor1 - place
    truck0 truck1 - truck
    hoist0 hoist1 hoist2 - hoist
    pallet0 pallet1 pallet2 - surface
    crate0 crate1 crate2 crate3 - crate
  )

  (:init
    (= (total-cost) 0)
    (= (crate-cost crate0) 1)
    (= (crate-cost crate1) 1)
    (= (crate-cost crate2) 1)
    (= (crate-cost crate3) 10)
    (= (drive-cost) 1)
    (clear crate0)
    (clear crate3)
    (clear crate2)
    (at-truck truck0 depot0)
    (at-truck truck1 depot0)
    (at-hoist hoist0 depot0)
    (available hoist0)
    (at-hoist hoist1 distributor0)
    (available hoist1)
    (at-hoist hoist2 distributor1)
    (available hoist2)
    (at-crate crate0 depot0)
    (on crate0 pallet0)
    (at-crate crate1 distributor1)
    (on crate1 pallet2)
    (at-crate crate2 distributor1)
    (on crate2 crate1)
    (at-crate crate3 distributor0)
    (on crate3 pallet1)
  )

  (:goal
    (and
      (on crate0 pallet2)
      (on crate1 crate3)
      (on crate2 pallet0)
      (on crate3 pallet1)
    )
  )

  (:metric minimize (total-cost))
)
