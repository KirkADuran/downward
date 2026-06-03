(define (domain miconic)
  (:requirements :strips :typing :action-costs)

  (:types passenger floor)

  (:predicates
    (lift-at ?f - floor)
    (origin ?p - passenger ?f - floor)
    (destin ?p - passenger ?f - floor)
    (boarded ?p - passenger)
    (served ?p - passenger)
    (above ?f1 - floor ?f2 - floor)
  )

  (:functions
    (total-cost)
    (passenger-cost ?p - passenger)
    (move-cost)
  )

  (:action board
    :parameters (?p - passenger ?f - floor)
    :precondition (and (lift-at ?f) (origin ?p ?f))
    :effect (and
      (boarded ?p)
      (increase (total-cost) (passenger-cost ?p)))
  )

  (:action depart
    :parameters (?p - passenger ?f - floor)
    :precondition (and (lift-at ?f) (destin ?p ?f) (boarded ?p))
    :effect (and
      (not (boarded ?p))
      (served ?p)
      (increase (total-cost) (passenger-cost ?p)))
  )

  (:action up
    :parameters (?from - floor ?to - floor)
    :precondition (and (lift-at ?from) (above ?to ?from))
    :effect (and
      (not (lift-at ?from))
      (lift-at ?to)
      (increase (total-cost) (move-cost)))
  )

  (:action down
    :parameters (?from - floor ?to - floor)
    :precondition (and (lift-at ?from) (above ?from ?to))
    :effect (and
      (not (lift-at ?from))
      (lift-at ?to)
      (increase (total-cost) (move-cost)))
  )
)
