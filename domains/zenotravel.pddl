(define (domain zenotravel)
  (:requirements :strips :typing :action-costs)

  (:types city aircraft person)

  (:predicates
    (at-aircraft ?a - aircraft ?c - city)
    (at-person ?p - person ?c - city)
    (in ?p - person ?a - aircraft)
  )

  (:functions
    (total-cost)
    (person-cost ?p - person)
    (fly-cost)
    (zoom-cost)
  )

  (:action board
    :parameters (?p - person ?a - aircraft ?c - city)
    :precondition (and (at-person ?p ?c) (at-aircraft ?a ?c))
    :effect (and
      (not (at-person ?p ?c))
      (in ?p ?a)
      (increase (total-cost) (person-cost ?p)))
  )

  (:action debark
    :parameters (?p - person ?a - aircraft ?c - city)
    :precondition (and (in ?p ?a) (at-aircraft ?a ?c))
    :effect (and
      (not (in ?p ?a))
      (at-person ?p ?c)
      (increase (total-cost) (person-cost ?p)))
  )

  (:action fly
    :parameters (?a - aircraft ?from - city ?to - city)
    :precondition (at-aircraft ?a ?from)
    :effect (and
      (not (at-aircraft ?a ?from))
      (at-aircraft ?a ?to)
      (increase (total-cost) (fly-cost)))
  )

  (:action zoom
    :parameters (?a - aircraft ?from - city ?to - city)
    :precondition (at-aircraft ?a ?from)
    :effect (and
      (not (at-aircraft ?a ?from))
      (at-aircraft ?a ?to)
      (increase (total-cost) (zoom-cost)))
  )
)
