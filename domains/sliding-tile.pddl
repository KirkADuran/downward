(define (domain sliding-tile)
  (:requirements :strips :typing :action-costs)

  (:types tile position)

  (:predicates
    (at ?t - tile ?p - position)
    (blank-at ?p - position)
    (adjacent ?p1 - position ?p2 - position)
  )

  (:functions
    (total-cost)
    (tile-cost ?t - tile)
  )

  (:action move
    :parameters (?t - tile ?from - position ?to - position)
    :precondition (and
      (at ?t ?from)
      (blank-at ?to)
      (adjacent ?from ?to))
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (not (blank-at ?to))
      (blank-at ?from)
      (increase (total-cost) (tile-cost ?t)))
  )
)
