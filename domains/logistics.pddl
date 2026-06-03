(define (domain logistics)
  (:requirements :strips :typing :action-costs)

  (:types
    city location vehicle package
    truck airplane - vehicle
  )

  (:predicates
    (in-city ?l - location ?c - city)
    (at ?x - vehicle ?l - location)
    (at-package ?p - package ?l - location)
    (in ?p - package ?v - vehicle)
  )

  (:functions
    (total-cost)
    (package-cost ?p - package)
    (drive-cost)
    (fly-cost)
  )

  (:action load-truck
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and (at-package ?p ?l) (at ?t ?l))
    :effect (and
      (not (at-package ?p ?l))
      (in ?p ?t)
      (increase (total-cost) (package-cost ?p)))
  )

  (:action unload-truck
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and (in ?p ?t) (at ?t ?l))
    :effect (and
      (not (in ?p ?t))
      (at-package ?p ?l)
      (increase (total-cost) (package-cost ?p)))
  )

  (:action load-airplane
    :parameters (?p - package ?a - airplane ?l - location)
    :precondition (and (at-package ?p ?l) (at ?a ?l))
    :effect (and
      (not (at-package ?p ?l))
      (in ?p ?a)
      (increase (total-cost) (package-cost ?p)))
  )

  (:action unload-airplane
    :parameters (?p - package ?a - airplane ?l - location)
    :precondition (and (in ?p ?a) (at ?a ?l))
    :effect (and
      (not (in ?p ?a))
      (at-package ?p ?l)
      (increase (total-cost) (package-cost ?p)))
  )

  (:action drive-truck
    :parameters (?t - truck ?from - location ?to - location ?c - city)
    :precondition (and (at ?t ?from) (in-city ?from ?c) (in-city ?to ?c))
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost) (drive-cost)))
  )

  (:action fly-airplane
    :parameters (?a - airplane ?from - location ?to - location)
    :precondition (at ?a ?from)
    :effect (and
      (not (at ?a ?from))
      (at ?a ?to)
      (increase (total-cost) (fly-cost)))
  )
)
