(define (domain driverlog)
  (:requirements :strips :typing :action-costs)

  (:types location truck driver package)

  (:predicates
    (at-truck ?t - truck ?l - location)
    (at-driver ?d - driver ?l - location)
    (at-package ?p - package ?l - location)
    (in ?p - package ?t - truck)
    (driving ?d - driver ?t - truck)
    (empty ?t - truck)
    (path ?from - location ?to - location)
    (link ?from - location ?to - location)
  )

  (:functions
    (total-cost)
    (package-cost ?p - package)
    (driver-cost ?d - driver)
    (drive-cost)
    (walk-cost)
  )

  (:action load-truck
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and (at-package ?p ?l) (at-truck ?t ?l))
    :effect (and
      (not (at-package ?p ?l))
      (in ?p ?t)
      (increase (total-cost) (package-cost ?p)))
  )

  (:action unload-truck
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and (in ?p ?t) (at-truck ?t ?l))
    :effect (and
      (not (in ?p ?t))
      (at-package ?p ?l)
      (increase (total-cost) (package-cost ?p)))
  )

  (:action board-truck
    :parameters (?d - driver ?t - truck ?l - location)
    :precondition (and (at-driver ?d ?l) (at-truck ?t ?l) (empty ?t))
    :effect (and
      (not (at-driver ?d ?l))
      (not (empty ?t))
      (driving ?d ?t)
      (increase (total-cost) (driver-cost ?d)))
  )

  (:action disembark-truck
    :parameters (?d - driver ?t - truck ?l - location)
    :precondition (and (driving ?d ?t) (at-truck ?t ?l))
    :effect (and
      (at-driver ?d ?l)
      (empty ?t)
      (not (driving ?d ?t))
      (increase (total-cost) (driver-cost ?d)))
  )

  (:action drive-truck
    :parameters (?d - driver ?t - truck ?from - location ?to - location)
    :precondition (and (driving ?d ?t) (at-truck ?t ?from) (link ?from ?to))
    :effect (and
      (not (at-truck ?t ?from))
      (at-truck ?t ?to)
      (increase (total-cost) (drive-cost)))
  )

  (:action walk
    :parameters (?d - driver ?from - location ?to - location)
    :precondition (and (at-driver ?d ?from) (path ?from ?to))
    :effect (and
      (not (at-driver ?d ?from))
      (at-driver ?d ?to)
      (increase (total-cost) (walk-cost)))
  )
)
