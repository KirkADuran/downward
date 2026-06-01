#ifndef SEARCH_ALGORITHMS_TYPE_WASTAR_H
#define SEARCH_ALGORITHMS_TYPE_WASTAR_H

#include "../search_algorithm.h"

#include <map>
#include <memory>
#include <optional>
#include <random>
#include <vector>

class Evaluator;
class PruningMethod;

namespace type_wastar {
class TypeWAStar : public SearchAlgorithm {
    struct Entry {
        StateID state_id;
        int g;
        int h;
        int f;
        int weighted_f;

        Entry(StateID state_id, int g, int h, int f, int weighted_f)
            : state_id(state_id),
              g(g),
              h(h),
              f(f),
              weighted_f(weighted_f) {
        }
    };

    std::shared_ptr<Evaluator> evaluator;
    std::shared_ptr<PruningMethod> pruning_method;
    bool reopen_closed_nodes;
    double weight;
    std::mt19937 rng;
    bool use_wastar_next;

    std::vector<Evaluator *> path_dependent_evaluators;
    std::map<int, std::vector<Entry>> open_by_f;
    std::map<int, std::vector<Entry>> open_by_weighted_f;

    bool compute_entry_values(
        EvaluationContext &eval_context, int &h, int &f,
        int &weighted_f) const;
    bool is_valid_entry(const Entry &entry);
    void prune_bucket(std::map<int, std::vector<Entry>>::iterator it);
    std::optional<int> get_min_live_key(
        std::map<int, std::vector<Entry>> &entries_by_key);
    void insert_open_entry(const Entry &entry);
    std::optional<Entry> select_wastar_entry();
    std::optional<Entry> select_type_focal_entry();
    std::optional<SearchNode> get_next_node_to_expand();
    SearchStatus expand(const SearchNode &node);
    void generate_successors(const SearchNode &node);

protected:
    virtual void initialize() override;
    virtual SearchStatus step() override;

public:
    TypeWAStar(
        const std::shared_ptr<Evaluator> &eval, bool reopen_closed,
        double weight, int random_seed,
        const std::shared_ptr<PruningMethod> &pruning, OperatorCost cost_type,
        int bound, double max_time, const std::string &description,
        utils::Verbosity verbosity);

    virtual void print_statistics() const override;
};
}

#endif
