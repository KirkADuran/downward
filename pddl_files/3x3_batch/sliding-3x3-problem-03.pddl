(define (problem sliding-tile-3x3-03)
  (:domain sliding-tile)

  (:objects
    tile1 tile2 tile3 tile4 tile5 tile6 tile7 tile8 - tile
    pos00 pos10 pos20 pos01 pos11 pos21 pos02 pos12 pos22 - position
  )

  (:init
    ;; Undirected adjacency on a 3x3 grid (listed both directions).
    (adjacent pos00 pos10) (adjacent pos10 pos00)
    (adjacent pos10 pos20) (adjacent pos20 pos10)
    (adjacent pos01 pos11) (adjacent pos11 pos01)
    (adjacent pos11 pos21) (adjacent pos21 pos11)
    (adjacent pos02 pos12) (adjacent pos12 pos02)
    (adjacent pos12 pos22) (adjacent pos22 pos12)
    (adjacent pos00 pos01) (adjacent pos01 pos00)
    (adjacent pos01 pos02) (adjacent pos02 pos01)
    (adjacent pos10 pos11) (adjacent pos11 pos10)
    (adjacent pos11 pos12) (adjacent pos12 pos11)
    (adjacent pos20 pos21) (adjacent pos21 pos20)
    (adjacent pos21 pos22) (adjacent pos22 pos21)

    (at tile2 pos00)
    (blank-at pos10)
    (at tile4 pos20)
    (at tile3 pos01)
    (at tile6 pos11)
    (at tile8 pos21)
    (at tile7 pos02)
    (at tile5 pos12)
    (at tile1 pos22)
  )

  (:goal
    (and
      (at tile1 pos00)
      (at tile2 pos10)
      (at tile3 pos20)
      (at tile4 pos01)
      (at tile5 pos11)
      (at tile6 pos21)
      (at tile7 pos02)
      (at tile8 pos12)
      (blank-at pos22)
    )
  )
)
