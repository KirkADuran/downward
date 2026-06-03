(define (problem depots-ipc-010-unit)
  (:domain depots)

  (:objects
    depot0 depot1 depot2 distributor0 distributor1 distributor2 - place
    truck0 truck1 - truck
    hoist0 hoist1 hoist2 hoist3 hoist4 hoist5 - hoist
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
    (clear crate1)
    (clear crate0)
    (clear crate4)
    (clear crate5)
    (clear pallet4)
    (clear crate3)
    (at-truck truck0 depot1)
    (at-truck truck1 depot2)
    (at-hoist hoist0 depot0)
    (available hoist0)
    (at-hoist hoist1 depot1)
    (available hoist1)
    (at-hoist hoist2 depot2)
    (available hoist2)
    (at-hoist hoist3 distributor0)
    (available hoist3)
    (at-hoist hoist4 distributor1)
    (available hoist4)
    (at-hoist hoist5 distributor2)
    (available hoist5)
    (at-crate crate0 depot1)
    (on crate0 pallet1)
    (at-crate crate1 depot0)
    (on crate1 pallet0)
    (at-crate crate2 distributor2)
    (on crate2 pallet5)
    (at-crate crate3 distributor2)
    (on crate3 crate2)
    (at-crate crate4 depot2)
    (on crate4 pallet2)
    (at-crate crate5 distributor0)
    (on crate5 pallet3)
  )

  (:goal
    (and
      (on crate0 crate4)
      (on crate2 pallet3)
      (on crate3 pallet0)
      (on crate4 pallet5)
    )
  )

  (:metric minimize (total-cost))
)
