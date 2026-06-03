(define (problem depots-ipc-001-unit)
  (:domain depots)

  (:objects
    depot0 distributor0 distributor1 - place
    truck0 truck1 - truck
    hoist0 hoist1 hoist2 - hoist
    pallet0 pallet1 pallet2 - surface
    crate0 crate1 - crate
  )

  (:init
    (= (total-cost) 0)
    (= (crate-cost crate0) 1)
    (= (crate-cost crate1) 1)
    (= (drive-cost) 1)
    (clear crate1)
    (clear crate0)
    (clear pallet2)
    (at-truck truck0 distributor1)
    (at-truck truck1 depot0)
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
  )

  (:goal
    (and
      (on crate0 pallet2)
      (on crate1 pallet1)
    )
  )

  (:metric minimize (total-cost))
)
