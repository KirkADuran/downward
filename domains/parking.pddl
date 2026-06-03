(define (domain parking)
  (:requirements :strips :typing :action-costs)

  (:types car curb)

  (:predicates
    (at ?c - car ?k - curb)
    (clear ?k - curb)
    (connected ?from - curb ?to - curb)
  )

  (:functions
    (total-cost)
    (car-cost ?c - car)
  )

  (:action move-car
    :parameters (?c - car ?from - curb ?to - curb)
    :precondition (and
      (at ?c ?from)
      (clear ?to)
      (connected ?from ?to))
    :effect (and
      (not (at ?c ?from))
      (at ?c ?to)
      (clear ?from)
      (not (clear ?to))
      (increase (total-cost) (car-cost ?c)))
  )
)
