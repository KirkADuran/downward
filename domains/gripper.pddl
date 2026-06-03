(define (domain gripper)
  (:requirements :strips :typing :action-costs)

  (:types room ball gripper)

  (:predicates
    (at-robby ?r - room)
    (at ?b - ball ?r - room)
    (free ?g - gripper)
    (carry ?b - ball ?g - gripper)
  )

  (:functions
    (total-cost)
    (ball-cost ?b - ball)
    (move-cost)
  )

  (:action move
    :parameters (?from - room ?to - room)
    :precondition (at-robby ?from)
    :effect (and
      (not (at-robby ?from))
      (at-robby ?to)
      (increase (total-cost) (move-cost)))
  )

  (:action pick
    :parameters (?b - ball ?r - room ?g - gripper)
    :precondition (and (at ?b ?r) (at-robby ?r) (free ?g))
    :effect (and
      (not (at ?b ?r))
      (not (free ?g))
      (carry ?b ?g)
      (increase (total-cost) (ball-cost ?b)))
  )

  (:action drop
    :parameters (?b - ball ?r - room ?g - gripper)
    :precondition (and (carry ?b ?g) (at-robby ?r))
    :effect (and
      (not (carry ?b ?g))
      (free ?g)
      (at ?b ?r)
      (increase (total-cost) (ball-cost ?b)))
  )
)
