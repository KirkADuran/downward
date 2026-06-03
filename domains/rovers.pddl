(define (domain rovers)
  (:requirements :strips :typing :action-costs)

  (:types rover waypoint store camera mode objective lander)

  (:predicates
    (at ?r - rover ?w - waypoint)
    (at-lander ?l - lander ?w - waypoint)
    (can-traverse ?r - rover ?from - waypoint ?to - waypoint)
    (equipped-for-soil-analysis ?r - rover)
    (equipped-for-rock-analysis ?r - rover)
    (equipped-for-imaging ?r - rover)
    (empty ?s - store)
    (store-of ?s - store ?r - rover)
    (full ?s - store)
    (have-soil-analysis ?w - waypoint)
    (have-rock-analysis ?w - waypoint)
    (visible ?from - waypoint ?to - waypoint)
    (visible-from ?o - objective ?w - waypoint)
    (on-board ?c - camera ?r - rover)
    (calibration-target ?c - camera ?o - objective)
    (supports ?c - camera ?m - mode)
    (calibrated ?c - camera ?r - rover)
    (have-image ?o - objective ?m - mode)
    (communicated-soil-data ?w - waypoint)
    (communicated-rock-data ?w - waypoint)
    (communicated-image-data ?o - objective ?m - mode)
    (channel-free ?l - lander)
  )

  (:functions
    (total-cost)
    (sample-cost ?w - waypoint)
    (image-cost ?o - objective)
    (rover-cost ?r - rover)
    (communicate-cost)
  )

  (:action navigate
    :parameters (?r - rover ?from - waypoint ?to - waypoint)
    :precondition (and (at ?r ?from) (can-traverse ?r ?from ?to))
    :effect (and
      (not (at ?r ?from))
      (at ?r ?to)
      (increase (total-cost) (rover-cost ?r)))
  )

  (:action sample-soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and
      (at ?r ?w)
      (store-of ?s ?r)
      (empty ?s)
      (equipped-for-soil-analysis ?r))
    :effect (and
      (not (empty ?s))
      (full ?s)
      (have-soil-analysis ?w)
      (increase (total-cost) (sample-cost ?w)))
  )

  (:action sample-rock
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and
      (at ?r ?w)
      (store-of ?s ?r)
      (empty ?s)
      (equipped-for-rock-analysis ?r))
    :effect (and
      (not (empty ?s))
      (full ?s)
      (have-rock-analysis ?w)
      (increase (total-cost) (sample-cost ?w)))
  )

  (:action drop
    :parameters (?r - rover ?s - store)
    :precondition (and (store-of ?s ?r) (full ?s))
    :effect (and
      (not (full ?s))
      (empty ?s)
      (increase (total-cost) (rover-cost ?r)))
  )

  (:action calibrate
    :parameters (?r - rover ?c - camera ?o - objective ?w - waypoint)
    :precondition (and
      (at ?r ?w)
      (equipped-for-imaging ?r)
      (on-board ?c ?r)
      (calibration-target ?c ?o)
      (visible-from ?o ?w))
    :effect (and
      (calibrated ?c ?r)
      (increase (total-cost) (image-cost ?o)))
  )

  (:action take-image
    :parameters (?r - rover ?w - waypoint ?o - objective ?c - camera ?m - mode)
    :precondition (and
      (at ?r ?w)
      (equipped-for-imaging ?r)
      (on-board ?c ?r)
      (calibrated ?c ?r)
      (supports ?c ?m)
      (visible-from ?o ?w))
    :effect (and
      (have-image ?o ?m)
      (increase (total-cost) (image-cost ?o)))
  )

  (:action communicate-soil-data
    :parameters (?r - rover ?l - lander ?w - waypoint ?from - waypoint ?to - waypoint)
    :precondition (and
      (at ?r ?from)
      (at-lander ?l ?to)
      (have-soil-analysis ?w)
      (visible ?from ?to)
      (channel-free ?l))
    :effect (and
      (communicated-soil-data ?w)
      (increase (total-cost) (communicate-cost)))
  )

  (:action communicate-rock-data
    :parameters (?r - rover ?l - lander ?w - waypoint ?from - waypoint ?to - waypoint)
    :precondition (and
      (at ?r ?from)
      (at-lander ?l ?to)
      (have-rock-analysis ?w)
      (visible ?from ?to)
      (channel-free ?l))
    :effect (and
      (communicated-rock-data ?w)
      (increase (total-cost) (communicate-cost)))
  )

  (:action communicate-image-data
    :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?from - waypoint ?to - waypoint)
    :precondition (and
      (at ?r ?from)
      (at-lander ?l ?to)
      (have-image ?o ?m)
      (visible ?from ?to)
      (channel-free ?l))
    :effect (and
      (communicated-image-data ?o ?m)
      (increase (total-cost) (communicate-cost)))
  )
)
