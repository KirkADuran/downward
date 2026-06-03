(define (domain depots)
  (:requirements :strips :typing :action-costs)

  (:types
    place truck hoist surface
    crate - surface
  )

  (:predicates
    (at-truck ?t - truck ?p - place)
    (at-hoist ?h - hoist ?p - place)
    (at-crate ?c - crate ?p - place)
    (on ?c - crate ?s - surface)
    (clear ?s - surface)
    (available ?h - hoist)
    (lifting ?h - hoist ?c - crate)
    (in ?c - crate ?t - truck)
  )

  (:functions
    (total-cost)
    (crate-cost ?c - crate)
    (drive-cost)
  )

  (:action drive
    :parameters (?t - truck ?from - place ?to - place)
    :precondition (at-truck ?t ?from)
    :effect (and
      (not (at-truck ?t ?from))
      (at-truck ?t ?to)
      (increase (total-cost) (drive-cost)))
  )

  (:action lift
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and
      (at-hoist ?h ?p)
      (available ?h)
      (at-crate ?c ?p)
      (on ?c ?s)
      (clear ?c))
    :effect (and
      (not (available ?h))
      (lifting ?h ?c)
      (clear ?s)
      (not (on ?c ?s))
      (not (at-crate ?c ?p))
      (increase (total-cost) (crate-cost ?c)))
  )

  (:action drop
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and
      (at-hoist ?h ?p)
      (lifting ?h ?c)
      (clear ?s))
    :effect (and
      (available ?h)
      (not (lifting ?h ?c))
      (at-crate ?c ?p)
      (on ?c ?s)
      (not (clear ?s))
      (clear ?c)
      (increase (total-cost) (crate-cost ?c)))
  )

  (:action load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and
      (at-hoist ?h ?p)
      (at-truck ?t ?p)
      (lifting ?h ?c))
    :effect (and
      (available ?h)
      (not (lifting ?h ?c))
      (in ?c ?t)
      (increase (total-cost) (crate-cost ?c)))
  )

  (:action unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and
      (at-hoist ?h ?p)
      (at-truck ?t ?p)
      (available ?h)
      (in ?c ?t))
    :effect (and
      (not (available ?h))
      (not (in ?c ?t))
      (lifting ?h ?c)
      (increase (total-cost) (crate-cost ?c)))
  )
)
