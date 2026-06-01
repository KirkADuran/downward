#include "alternating_wastar_focal_random.h"

#include "../evaluation_context.h"
#include "../evaluator.h"
#include "../plugins/plugin.h"
#include "../pruning_method.h"
#include "../task_utils/successor_generator.h"
#include "../utils/logging.h"
#include "../utils/system.h"

#include <cassert>
#include <iostream>
#include <limits>
#include <set>

using namespace std;

namespace alternating_wastar_focal_random {
static int clamp_to_int(long long value) {
    if (value > numeric_limits<int>::max()) {
        return numeric_limits<int>::max();
    }
    return static_cast<int>(value);
}

AlternatingWAStarFocalRandom::AlternatingWAStarFocalRandom(
    const shared_ptr<Evaluator> &eval, bool reopen_closed, int wastar_weight,
    double focal_weight, int random_seed,
    const shared_ptr<PruningMethod> &pruning, OperatorCost cost_type,
    int bound, double max_time, const string &description,
    utils::Verbosity verbosity)
    : SearchAlgorithm(cost_type, bound, max_time, description, verbosity),
      evaluator(eval),
      pruning_method(pruning),
      reopen_closed_nodes(reopen_closed),
      wastar_weight(wastar_weight),
      focal_weight(focal_weight),
      rng(random_seed),
      use_wastar_next(true) {
    if (wastar_weight < 1) {
        cerr << "wastar_weight must be >= 1" << endl;
        utils::exit_with(utils::ExitCode::SEARCH_INPUT_ERROR);
    }
    if (focal_weight < 1.0) {
        cerr << "focal_weight must be >= 1" << endl;
        utils::exit_with(utils::ExitCode::SEARCH_INPUT_ERROR);
    }
}

void AlternatingWAStarFocalRandom::initialize() {
    log << "Conducting alternating WA*/focal-random search"
        << (reopen_closed_nodes ? " with" : " without")
        << " reopening closed nodes, WA* weight = " << wastar_weight
        << ", focal weight = " << focal_weight
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
    int h;
    int f;
    int weighted_f;
    if (!compute_entry_values(eval_context, h, f, weighted_f)) {
        log << "Initial state is a dead end." << endl;
    } else {
        SearchNode node = search_space.get_node(initial_state);
        node.open_initial();
        insert_open_entry(Entry(initial_state.get_id(), 0, h, f, weighted_f));
        if (search_progress.check_progress(eval_context)) {
            statistics.print_checkpoint_line(0);
        }
        statistics.report_f_value_progress(f);
    }

    print_initial_evaluator_values(eval_context);
    pruning_method->initialize(task);
}

bool AlternatingWAStarFocalRandom::compute_entry_values(
    EvaluationContext &eval_context, int &h, int &f, int &weighted_f) const {
    if (eval_context.is_evaluator_value_infinite(evaluator.get())) {
        return false;
    }
    h = eval_context.get_evaluator_value(evaluator.get());
    int g = eval_context.get_g_value();
    f = clamp_to_int(static_cast<long long>(g) + h);
    weighted_f = clamp_to_int(
        static_cast<long long>(g) + static_cast<long long>(wastar_weight) * h);
    return true;
}

bool AlternatingWAStarFocalRandom::is_valid_entry(const Entry &entry) {
    State state = state_registry.lookup_state(entry.state_id);
    SearchNode node = search_space.get_node(state);
    return node.is_open() && node.get_g() == entry.g;
}

void AlternatingWAStarFocalRandom::prune_bucket(
    map<int, vector<Entry>>::iterator it) {
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

optional<int> AlternatingWAStarFocalRandom::get_min_live_key(
    map<int, vector<Entry>> &entries_by_key) {
    while (!entries_by_key.empty()) {
        auto it = entries_by_key.begin();
        prune_bucket(it);
        if (!it->second.empty()) {
            return it->first;
        }
        entries_by_key.erase(it);
    }
    return nullopt;
}

void AlternatingWAStarFocalRandom::insert_open_entry(const Entry &entry) {
    open_by_f[entry.f].push_back(entry);
    open_by_weighted_f[entry.weighted_f].push_back(entry);
}

optional<AlternatingWAStarFocalRandom::Entry>
AlternatingWAStarFocalRandom::select_wastar_entry() {
    optional<int> maybe_key = get_min_live_key(open_by_weighted_f);
    if (!maybe_key) {
        return nullopt;
    }
    auto it = open_by_weighted_f.find(*maybe_key);
    assert(it != open_by_weighted_f.end());
    prune_bucket(it);
    if (it->second.empty()) {
        open_by_weighted_f.erase(it);
        return select_wastar_entry();
    }
    return it->second.front();
}

optional<AlternatingWAStarFocalRandom::Entry>
AlternatingWAStarFocalRandom::select_focal_random_entry() {
    optional<int> maybe_f_min = get_min_live_key(open_by_f);
    if (!maybe_f_min) {
        return nullopt;
    }

    double threshold = static_cast<double>(*maybe_f_min) * focal_weight;
    optional<Entry> selected;
    int num_candidates = 0;

    auto it = open_by_f.begin();
    while (it != open_by_f.end() && static_cast<double>(it->first) <= threshold) {
        prune_bucket(it);
        if (it->second.empty()) {
            it = open_by_f.erase(it);
            continue;
        }
        for (const Entry &entry : it->second) {
            ++num_candidates;
            uniform_int_distribution<int> dist(1, num_candidates);
            if (dist(rng) == 1) {
                selected = entry;
            }
        }
        ++it;
    }

    return selected;
}

optional<SearchNode> AlternatingWAStarFocalRandom::get_next_node_to_expand() {
    while (true) {
        optional<Entry> selected = use_wastar_next ? select_wastar_entry()
                                                  : select_focal_random_entry();
        if (!selected) {
            selected = use_wastar_next ? select_focal_random_entry()
                                      : select_wastar_entry();
        }
        if (!selected) {
            return nullopt;
        }

        State state = state_registry.lookup_state(selected->state_id);
        SearchNode node = search_space.get_node(state);
        if (!is_valid_entry(*selected)) {
            continue;
        }

        use_wastar_next = !use_wastar_next;
        statistics.report_f_value_progress(selected->f);
        node.close();
        return node;
    }
}

SearchStatus AlternatingWAStarFocalRandom::step() {
    optional<SearchNode> node = get_next_node_to_expand();
    if (!node.has_value()) {
        log << "Completely explored state space -- no solution!" << endl;
        return FAILED;
    }
    return expand(node.value());
}

SearchStatus AlternatingWAStarFocalRandom::expand(const SearchNode &node) {
    statistics.inc_expanded();

    const State &state = node.get_state();
    if (check_goal_and_set_plan(state)) {
        return SOLVED;
    }

    generate_successors(node);
    return IN_PROGRESS;
}

void AlternatingWAStarFocalRandom::generate_successors(
    const SearchNode &node) {
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
            int h;
            int f;
            int weighted_f;
            if (!compute_entry_values(succ_eval_context, h, f, weighted_f)) {
                succ_node.mark_as_dead_end();
                statistics.inc_dead_ends();
                continue;
            }

            succ_node.open_new_node(node, op, adjusted_cost);
            insert_open_entry(
                Entry(succ_state.get_id(), succ_g, h, f, weighted_f));
            if (search_progress.check_progress(succ_eval_context)) {
                statistics.print_checkpoint_line(succ_node.get_g());
            }
        } else if (succ_node.get_g() > succ_g) {
            EvaluationContext succ_eval_context(
                succ_state, succ_g, false, &statistics);
            int h;
            int f;
            int weighted_f;
            if (!compute_entry_values(succ_eval_context, h, f, weighted_f)) {
                continue;
            }

            if (succ_node.is_open()) {
                succ_node.update_open_node_parent(node, op, adjusted_cost);
                insert_open_entry(
                    Entry(succ_state.get_id(), succ_g, h, f, weighted_f));
            } else if (succ_node.is_closed() && reopen_closed_nodes) {
                statistics.inc_reopened();
                succ_node.reopen_closed_node(node, op, adjusted_cost);
                insert_open_entry(
                    Entry(succ_state.get_id(), succ_g, h, f, weighted_f));
            } else {
                assert(succ_node.is_closed() && !reopen_closed_nodes);
                succ_node.update_closed_node_parent(node, op, adjusted_cost);
            }
        }
    }
}

void AlternatingWAStarFocalRandom::print_statistics() const {
    statistics.print_detailed_statistics();
    search_space.print_statistics();
    pruning_method->print_statistics();
}

class AlternatingWAStarFocalRandomFeature
    : public plugins::TypedFeature<SearchAlgorithm, AlternatingWAStarFocalRandom> {
public:
    AlternatingWAStarFocalRandomFeature()
        : TypedFeature("alternating_wastar_focal_random") {
        document_title("Alternating WA*/focal random search");
        document_synopsis(
            "Alternates between WA* expansion and random expansion from the "
            "bounded focal subset f <= focal_w * f_min.");

        add_option<shared_ptr<Evaluator>>("eval", "evaluator for h-value");
        add_option<bool>("reopen_closed", "reopen closed nodes", "false");
        add_option<int>("wastar_w", "weight for WA*", "5");
        add_option<double>("focal_w", "weight for the focal list", "1.5");
        add_option<int>("random_seed", "seed for random focal selection", "0");
        add_search_pruning_options_to_feature(*this);
        add_search_algorithm_options_to_feature(
            *this, "alternating_wastar_focal_random");
    }

    virtual shared_ptr<AlternatingWAStarFocalRandom> create_component(
        const plugins::Options &opts) const override {
        return plugins::make_shared_from_arg_tuples<AlternatingWAStarFocalRandom>(
            opts.get<shared_ptr<Evaluator>>("eval"),
            opts.get<bool>("reopen_closed"),
            opts.get<int>("wastar_w"),
            opts.get<double>("focal_w"),
            opts.get<int>("random_seed"),
            get_search_pruning_arguments_from_options(opts),
            get_search_algorithm_arguments_from_options(opts));
    }
};

static plugins::FeaturePlugin<AlternatingWAStarFocalRandomFeature> _plugin;
}
