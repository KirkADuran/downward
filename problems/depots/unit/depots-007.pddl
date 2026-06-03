(define (problem depots-ipc-007-unit)
  (:domain depots)

  (:objects
    depot0 distributor0 distributor1 - place
    truck0 truck1 - truck
    hoist0 hoist1 hoist2 - hoist
    pallet0 pallet1 pallet2 pallet3 pallet4 pallet5 - surface
    crate0 crate1 crate2 crate3 crate4 crate5 - crate
  )

  (:init
    (= (total-cost) 0)
    (= (crate-cost crate0) 1)
    (= (crate-cost crate1) 1)
    (= (crate-cost crate2) 1)
    (= (crate-cost crate3) 1)
    (= (crate-cost crate4) 1)
    (= (crate-cost crate5) 1)
    (= (drive-cost) 1)
    (clear crate5)
    (clear pallet1)
    (clear crate3)
    (clear pallet3)
    (clear crate4)
    (clear crate1)
    (at-truck truck0 distributor1)
    (at-truck truck1 depot0)
    (at-hoist hoist0 depot0)
    (available hoist0)
    (at-hoist hoist1 distributor0)
    (available hoist1)
    (at-hoist hoist2 distributor1)
    (available hoist2)
    (at-crate crate0 distributor0)
    (on crate0 pallet4)
    (at-crate crate1 distributor1)
    (on crate1 pallet5)
    (at-crate crate2 distributor1)
    (on crate2 pallet2)
    (at-crate crate3 distributor1)
    (on crate3 crate2)
    (at-crate crate4 distributor0)
    (on crate4 crate0)
    (at-crate crate5 depot0)
    (on crate5 pallet0)
  )

  (:goal
    (and
      (on crate0 pallet3)
      (on crate1 crate4)
      (on crate3 pallet1)
      (on crate4 pallet5)
      (on crate5 crate1)
    )
  )

  (:metric minimize (total-cost))
)
