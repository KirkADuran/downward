#include "manhattan_heuristic.h"

#include "../plugins/plugin.h"
#include "../utils/logging.h"

#include <cctype>
#include <cstdlib>
#include <string>

using namespace std;

namespace manhattan_heuristic {
ManhattanHeuristic::ManhattanHeuristic(
    const shared_ptr<AbstractTask> &transform, bool cache_estimates,
    const string &description, utils::Verbosity verbosity)
    : Heuristic(transform, cache_estimates, description, verbosity),
      has_manhattan_structure(false) {
    if (log.is_at_least_normal()) {
        log << "Initializing Manhattan heuristic..." << endl;
    }

    VariablesProxy vars = task_proxy.get_variables();
    value_positions.resize(vars.size());
    goal_positions.resize(vars.size());

    for (VariableProxy var : vars) {
        vector<optional<Pos>> positions_for_values(var.get_domain_size());
        bool all_values_match_positions = true;
        for (int value = 0; value < var.get_domain_size(); ++value) {
            string fact_name = var.get_fact(value).get_name();
            optional<Pos> pos = parse_pos_from_fact_name(fact_name);
            if (!pos) {
                all_values_match_positions = false;
                break;
            }
            positions_for_values[value] = pos;
        }
        if (all_values_match_positions) {
            value_positions[var.get_id()] = move(positions_for_values);
        }
    }

    for (FactProxy goal : task_proxy.get_goals()) {
        int var_id = goal.get_variable().get_id();
        optional<Pos> pos = parse_pos_from_fact_name(goal.get_name());
        if (pos) {
            goal_positions[var_id] = pos;
        }
    }

    for (VariableProxy var : vars) {
        int var_id = var.get_id();
        if (!value_positions[var_id].empty() && goal_positions[var_id]) {
            has_manhattan_structure = true;
            break;
        }
    }

    if (!has_manhattan_structure && log.is_at_least_normal()) {
        log << "Manhattan heuristic: no matching tile-position structure found; "
               "returns 0."
            << endl;
    }
}

optional<ManhattanHeuristic::Pos> ManhattanHeuristic::parse_pos_from_fact_name(
    const string &name) const {
    // Expected shape includes "posRC", e.g. "Atom at(tile1, pos23)".
    size_t pos_index = name.find("pos");
    if (pos_index == string::npos || pos_index + 4 >= name.size()) {
        return nullopt;
    }

    char row_char = name[pos_index + 3];
    char col_char = name[pos_index + 4];
    if (!isdigit(static_cast<unsigned char>(row_char)) ||
        !isdigit(static_cast<unsigned char>(col_char))) {
        return nullopt;
    }

    Pos pos;
    pos.row = row_char - '0';
    pos.col = col_char - '0';
    return pos;
}

int ManhattanHeuristic::compute_heuristic(const State &ancestor_state) {
    if (!has_manhattan_structure) {
        return 0;
    }

    State state = convert_ancestor_state(ancestor_state);
    int total = 0;
    for (VariableProxy var : task_proxy.get_variables()) {
        int var_id = var.get_id();
        if (value_positions[var_id].empty() || !goal_positions[var_id]) {
            continue;
        }

        int value = state[var].get_value();
        const optional<Pos> &current_pos = value_positions[var_id][value];
        if (!current_pos) {
            continue;
        }
        const Pos &goal_pos = *goal_positions[var_id];
        total += abs(current_pos->row - goal_pos.row) +
                 abs(current_pos->col - goal_pos.col);
    }
    return total;
}

class ManhattanHeuristicFeature
    : public plugins::TypedFeature<Evaluator, ManhattanHeuristic> {
public:
    ManhattanHeuristicFeature() : TypedFeature("manhattan") {
        document_title("Manhattan distance heuristic");
        document_synopsis(
            "Sums Manhattan distances for variables with facts that match "
            "at(tileX, posRC)-style naming.");

        add_heuristic_options_to_feature(*this, "manhattan");

        document_language_support("action costs", "ignored by design");
        document_language_support("conditional effects", "supported");
        document_language_support("axioms", "supported");

        document_property("admissible", "no general guarantee");
        document_property("consistent", "no general guarantee");
        document_property("safe", "yes");
        document_property("preferred operators", "no");
    }

    virtual shared_ptr<ManhattanHeuristic> create_component(
        const plugins::Options &opts) const override {
        return plugins::make_shared_from_arg_tuples<ManhattanHeuristic>(
            get_heuristic_arguments_from_options(opts));
    }
};

static plugins::FeaturePlugin<ManhattanHeuristicFeature> _plugin;
}
