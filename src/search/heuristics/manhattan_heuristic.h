#ifndef HEURISTICS_MANHATTAN_HEURISTIC_H
#define HEURISTICS_MANHATTAN_HEURISTIC_H

#include "../heuristic.h"

#include <optional>
#include <vector>

namespace manhattan_heuristic {
class ManhattanHeuristic : public Heuristic {
    struct Pos {
        int row;
        int col;
    };

    // For each variable id, cache positions for each value if they match
    // at(tileX, posRC)-style facts. Empty means "not a tile-position variable".
    std::vector<std::vector<std::optional<Pos>>> value_positions;
    // Goal coordinate for each variable id, if available.
    std::vector<std::optional<Pos>> goal_positions;
    bool has_manhattan_structure;

    std::optional<Pos> parse_pos_from_fact_name(const std::string &name) const;

protected:
    virtual int compute_heuristic(const State &ancestor_state) override;

public:
    ManhattanHeuristic(
        const std::shared_ptr<AbstractTask> &transform, bool cache_estimates,
        const std::string &description, utils::Verbosity verbosity);
};
}

#endif
