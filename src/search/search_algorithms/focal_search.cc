#include "focal_search.h"

#include "../evaluation_context.h"
#include "../evaluator.h"
#include "../plugins/plugin.h"
#include "../pruning_method.h"
#include "../task_utils/successor_generator.h"
#include "../utils/component_errors.h"
#include "../utils/logging.h"
#include "../utils/system.h"

#include <cassert>
#include <cmath>
#include <iostream>
#include <limits>
#include <set>

using namespace std;

namespace focal_search {
FocalSearch::FocalSearch(
    const shared_ptr<Evaluator> &eval, bool reopen_closed,
    double focal_weight, int random_seed,
    const shared_ptr<PruningMethod> &pruning, OperatorCost cost_type,
    int bound, double max_time, const string &description,
    utils::Verbosity verbosity)
    : SearchAlgorithm(cost_type, bound, max_time, description, verbosity),
      evaluator(eval),
      pruning_method(pruning),
      reopen_closed_nodes(reopen_closed),
      focal_weight(focal_weight),
      rng(random_seed) {
    if (focal_weight < 1.0) {
        cerr << "focal weight must be >= 1" << endl;
        utils::exit_with(utils::ExitCode::SEARCH_INPUT_ERROR);
    }
}

void FocalSearch::initialize() {
    log << "Conducting focal search"
        << (reopen_closed_nodes ? " with" : " without")
        << " reopening closed nodes, focal weight = " << focal_weight
        << ", (real) bound = " << bound << endl;

    set<Evaluator *> evals;
    evaluator->get_path_dependent_evaluators(evals);
    path_dependent_evaluators.assign(evals.begin(), evals.end());

    State initial_state = state_registry.get_initial_state();
    for (Evaluator *eval : path_dependent_evaluators) {
        eval->notify_initial_state(initial_state);
    }

    EvaluationContext eval_context(initial_state, 0, true, &statistics);
    statistics.inc_evaluated_states();
    int f = compute_f(eval_context);

    if (f == numeric_limits<int>::max()) {
        log << "Initial state is a dead end." << endl;
    } else {
        SearchNode node = search_space.get_node(initial_state);
        node.open_initial();
        insert_open_entry(initial_state.get_id(), 0, f);
        if (search_progress.check_progress(eval_context)) {
            statistics.print_checkpoint_line(0);
        }
        statistics.report_f_value_progress(f);
    }

    print_initial_evaluator_values(eval_context);
    pruning_method->initialize(task);
}

int FocalSearch::compute_f(EvaluationContext &eval_context) const {
    if (eval_context.is_evaluator_value_infinite(evaluator.get())) {
        return numeric_limits<int>::max();
    }
    int h = eval_context.get_evaluator_value(evaluator.get());
    int g = eval_context.get_g_value();
    if (h > numeric_limits<int>::max() - g) {
        return numeric_limits<int>::max();
    }
    return g + h;
}

bool FocalSearch::is_valid_entry(const Entry &entry) {
    State state = state_registry.lookup_state(entry.state_id);
    SearchNode node = search_space.get_node(state);
    return node.is_open() && node.get_g() == entry.g;
}

void FocalSearch::prune_bucket(map<int, vector<Entry>>::iterator it) {
    vector<Entry> &entries = it->second;
    vector<Entry> live_entries;
    live_entries.reserve(entries.size());
    for (const Entry &entry : entries) {
        if (is_valid_entry(entry)) {
            live_entries.push_back(entry);
        }
    }
    entries.swap(live_entries);
}

optional<int> FocalSearch::get_f_min() {
    while (!open_by_f.empty()) {
        auto it = open_by_f.begin();
        prune_bucket(it);
        if (!it->second.empty()) {
            return it->first;
        }
        open_by_f.erase(it);
    }
    return nullopt;
}

void FocalSearch::insert_open_entry(StateID state_id, int g, int f) {
    open_by_f[f].emplace_back(state_id, g, f);
}

optional<SearchNode> FocalSearch::get_next_node_to_expand() {
    optional<int> maybe_f_min = get_f_min();
    if (!maybe_f_min) {
        return nullopt;
    }

    double threshold = static_cast<double>(*maybe_f_min) * focal_weight;
    optional<Entry> selected;
    int num_candidates = 0;

    for (auto it = open_by_f.begin();
         it != open_by_f.end() && static_cast<double>(it->first) <= threshold;
         ++it) {
        prune_bucket(it);
        for (const Entry &entry : it->second) {
            ++num_candidates;
            uniform_int_distribution<int> dist(1, num_candidates);
            if (dist(rng) == 1) {
                selected = entry;
            }
        }
    }

    if (!selected) {
        return get_next_node_to_expand();
    }

    State state = state_registry.lookup_state(selected->state_id);
    SearchNode node = search_space.get_node(state);
    if (!is_valid_entry(*selected)) {
        return get_next_node_to_expand();
    }

    EvaluationContext eval_context(state, node.get_g(), false, &statistics);
    statistics.report_f_value_progress(selected->f);
    node.close();
    return node;
}

SearchStatus FocalSearch::step() {
    optional<SearchNode> node = get_next_node_to_expand();
    if (!node.has_value()) {
        log << "Completely explored state space -- no solution!" << endl;
        return FAILED;
    }
    return expand(node.value());
}

SearchStatus FocalSearch::expand(const SearchNode &node) {
    statistics.inc_expanded();

    const State &state = node.get_state();
    if (check_goal_and_set_plan(state)) {
        return SOLVED;
    }

    generate_successors(node);
    return IN_PROGRESS;
}

void FocalSearch::generate_successors(const SearchNode &node) {
    const State &state = node.get_state();

    vector<OperatorID> applicable_operators;
    successor_generator.generate_applicable_ops(state, applicable_operators);
    pruning_method->prune_operators(state, applicable_operators);

    for (OperatorID op_id : applicable_operators) {
        OperatorProxy op = task_proxy.get_operators()[op_id];
        if ((node.get_real_g() + op.get_cost()) >= bound) {
            continue;
        }

        State succ_state = state_registry.get_successor_state(state, op);
        statistics.inc_generated();

        SearchNode succ_node = search_space.get_node(succ_state);

        for (Evaluator *eval : path_dependent_evaluators) {
            eval->notify_state_transition(state, op_id, succ_state);
        }

        if (succ_node.is_dead_end()) {
            continue;
        }

        int adjusted_cost = get_adjusted_cost(op);
        int succ_g = node.get_g() + adjusted_cost;

        if (succ_node.is_new()) {
            EvaluationContext succ_eval_context(
                succ_state, succ_g, false, &statistics);
            statistics.inc_evaluated_states();
            int succ_f = compute_f(succ_eval_context);
            if (succ_f == numeric_limits<int>::max()) {
                succ_node.mark_as_dead_end();
                statistics.inc_dead_ends();
                continue;
            }

            succ_node.open_new_node(node, op, adjusted_cost);
            insert_open_entry(succ_state.get_id(), succ_g, succ_f);
            if (search_progress.check_progress(succ_eval_context)) {
                statistics.print_checkpoint_line(succ_node.get_g());
            }
        } else if (succ_node.get_g() > succ_g) {
            if (succ_node.is_open()) {
                succ_node.update_open_node_parent(node, op, adjusted_cost);
                EvaluationContext succ_eval_context(
                    succ_state, succ_node.get_g(), false, &statistics);
                int succ_f = compute_f(succ_eval_context);
                insert_open_entry(succ_state.get_id(), succ_node.get_g(), succ_f);
            } else if (succ_node.is_closed() && reopen_closed_nodes) {
                statistics.inc_reopened();
                succ_node.reopen_closed_node(node, op, adjusted_cost);
                EvaluationContext succ_eval_context(
                    succ_state, succ_node.get_g(), false, &statistics);
                int succ_f = compute_f(succ_eval_context);
                insert_open_entry(succ_state.get_id(), succ_node.get_g(), succ_f);
            } else {
                assert(succ_node.is_closed() && !reopen_closed_nodes);
                succ_node.update_closed_node_parent(node, op, adjusted_cost);
            }
        }
    }
}

void FocalSearch::print_statistics() const {
    statistics.print_detailed_statistics();
    search_space.print_statistics();
    pruning_method->print_statistics();
}

class FocalSearchFeature
    : public plugins::TypedFeature<SearchAlgorithm, FocalSearch> {
public:
    FocalSearchFeature() : TypedFeature("focal") {
        document_title("Focal search");
        document_synopsis(
            "Maintains all open nodes ordered by f=g+h and expands a random "
            "node from the focal subset with f <= weight * f_min.");

        add_option<shared_ptr<Evaluator>>("eval", "evaluator for h-value");
        add_option<bool>("reopen_closed", "reopen closed nodes", "false");
        add_option<double>("w", "focal weight", "1.5");
        add_option<int>("random_seed", "seed for focal node sampling", "0");
        add_search_pruning_options_to_feature(*this);
        add_search_algorithm_options_to_feature(*this, "focal");
    }

    virtual shared_ptr<FocalSearch> create_component(
        const plugins::Options &opts) const override {
        return plugins::make_shared_from_arg_tuples<FocalSearch>(
            opts.get<shared_ptr<Evaluator>>("eval"),
            opts.get<bool>("reopen_closed"),
            opts.get<double>("w"),
            opts.get<int>("random_seed"),
            get_search_pruning_arguments_from_options(opts),
            get_search_algorithm_arguments_from_options(opts));
    }
};

static plugins::FeaturePlugin<FocalSearchFeature> _plugin;
}
