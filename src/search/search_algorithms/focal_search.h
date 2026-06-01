#ifndef SEARCH_ALGORITHMS_FOCAL_SEARCH_H
#define SEARCH_ALGORITHMS_FOCAL_SEARCH_H

#include "../search_algorithm.h"

#include <map>
#include <memory>
#include <optional>
#include <random>
#include <vector>

class Evaluator;
class PruningMethod;

namespace focal_search {
class FocalSearch : public SearchAlgorithm {
    struct Entry {
        StateID state_id;
        int g;
        int f;

        Entry(StateID state_id, int g, int f)
            : state_id(state_id), g(g), f(f) {
        }
    };

    std::shared_ptr<Evaluator> evaluator;
    std::shared_ptr<PruningMethod> pruning_method;
    bool reopen_closed_nodes;
    double focal_weight;
    std::mt19937 rng;

    std::vector<Evaluator *> path_dependent_evaluators;
    std::map<int, std::vector<Entry>> open_by_f;

    int compute_f(EvaluationContext &eval_context) const;
    bool is_valid_entry(const Entry &entry);
    void prune_bucket(std::map<int, std::vector<Entry>>::iterator it);
    std::optional<int> get_f_min();
    void insert_open_entry(StateID state_id, int g, int f);
    std::optional<SearchNode> get_next_node_to_expand();
    SearchStatus expand(const SearchNode &node);
    void generate_successors(const SearchNode &node);

protected:
    virtual void initialize() override;
    virtual SearchStatus step() override;

public:
    FocalSearch(
        const std::shared_ptr<Evaluator> &eval, bool reopen_closed,
        double focal_weight, int random_seed,
        const std::shared_ptr<PruningMethod> &pruning, OperatorCost cost_type,
        int bound, double max_time, const std::string &description,
        utils::Verbosity verbosity);

    virtual void print_statistics() const override;
};
}

#endif
