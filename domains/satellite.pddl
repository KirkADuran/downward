(define (domain satellite)
  (:requirements :strips :typing :action-costs)

  (:types satellite instrument mode direction)

  (:predicates
    (pointing ?s - satellite ?d - direction)
    (power-avail ?s - satellite)
    (power-on ?i - instrument)
    (calibrated ?i - instrument)
    (on-board ?i - instrument ?s - satellite)
    (supports ?i - instrument ?m - mode)
    (calibration-target ?i - instrument ?d - direction)
    (have-image ?d - direction ?m - mode)
  )

  (:functions
    (total-cost)
    (target-cost ?d - direction)
    (instrument-cost ?i - instrument)
    (satellite-move-cost ?s - satellite)
  )

  (:action turn-to
    :parameters (?s - satellite ?from - direction ?to - direction)
    :precondition (pointing ?s ?from)
    :effect (and
      (not (pointing ?s ?from))
      (pointing ?s ?to)
      (increase (total-cost) (satellite-move-cost ?s)))
  )

  (:action switch-on
    :parameters (?i - instrument ?s - satellite)
    :precondition (and (on-board ?i ?s) (power-avail ?s))
    :effect (and
      (power-on ?i)
      (not (power-avail ?s))
      (increase (total-cost) (instrument-cost ?i)))
  )

  (:action switch-off
    :parameters (?i - instrument ?s - satellite)
    :precondition (and (on-board ?i ?s) (power-on ?i))
    :effect (and
      (not (power-on ?i))
      (power-avail ?s)
      (increase (total-cost) (instrument-cost ?i)))
  )

  (:action calibrate
    :parameters (?s - satellite ?i - instrument ?d - direction)
    :precondition (and
      (on-board ?i ?s)
      (power-on ?i)
      (pointing ?s ?d)
      (calibration-target ?i ?d))
    :effect (and
      (calibrated ?i)
      (increase (total-cost) (target-cost ?d)))
  )

  (:action take-image
    :parameters (?s - satellite ?d - direction ?i - instrument ?m - mode)
    :precondition (and
      (on-board ?i ?s)
      (power-on ?i)
      (calibrated ?i)
      (supports ?i ?m)
      (pointing ?s ?d))
    :effect (and
      (have-image ?d ?m)
      (increase (total-cost) (target-cost ?d)))
  )
)
