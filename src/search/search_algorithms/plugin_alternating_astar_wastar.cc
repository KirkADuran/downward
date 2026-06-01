#include "eager_search.h"

#include "../evaluators/g_evaluator.h"
#include "../evaluators/sum_evaluator.h"
#include "../evaluators/weighted_evaluator.h"
#include "../open_lists/alternation_open_list.h"
#include "../open_lists/best_first_open_list.h"
#include "../plugins/plugin.h"

#include <memory>
#include <vector>

using namespace std;

namespace plugin_alternating_astar_wastar {
using GEval = g_evaluator::GEvaluator;
using SumEval = sum_evaluator::SumEvaluator;
using WeightedEval = weighted_evaluator::WeightedEvaluator;

static shared_ptr<OpenListFactory> create_alternating_open_list_factory(
    const shared_ptr<Evaluator> &h_eval, int w, utils::Verbosity verbosity) {
    shared_ptr<GEval> g_eval =
        make_shared<GEval>("alternating_astar_wastar.g_eval", verbosity);
    shared_ptr<Evaluator> astar_f = make_shared<SumEval>(
        vector<shared_ptr<Evaluator>>({g_eval, h_eval}),
        "alternating_astar_wastar.astar_f_eval", verbosity);

    shared_ptr<Evaluator> weighted_h = h_eval;
    if (w != 1) {
        weighted_h = make_shared<WeightedEval>(
            h_eval, w, "alternating_astar_wastar.weighted_h_eval", verbosity);
    }
    shared_ptr<Evaluator> wastar_f = make_shared<SumEval>(
        vector<shared_ptr<Evaluator>>({g_eval, weighted_h}),
        "alternating_astar_wastar.wastar_f_eval", verbosity);

    vector<shared_ptr<OpenListFactory>> sublists = {
        make_shared<standard_scalar_open_list::BestFirstOpenListFactory>(
            astar_f, false),
        make_shared<standard_scalar_open_list::BestFirstOpenListFactory>(
            wastar_f, false),
    };
    return make_shared<alternation_open_list::AlternationOpenListFactory>(
        sublists, 0);
}

class AlternatingAStarWAStarSearchFeature
    : public plugins::TypedFeature<SearchAlgorithm, eager_search::EagerSearch> {
public:
    AlternatingAStarWAStarSearchFeature()
        : TypedFeature("alternating_astar_wastar") {
        document_title("Alternating A*/WA* search (eager)");
        document_synopsis(
            "Alternates expansion between two queues: one ranked by g+h "
            "(A*) and one ranked by g+w*h (WA*).");

        add_option<shared_ptr<Evaluator>>("eval", "evaluator for h-value");
        add_option<int>("w", "weight for the WA* queue", "5");
        add_option<bool>("reopen_closed", "reopen closed nodes", "true");
        eager_search::add_eager_search_options_to_feature(
            *this, "alternating_astar_wastar");
    }

    virtual shared_ptr<eager_search::EagerSearch> create_component(
        const plugins::Options &opts) const override {
        plugins::Options options_copy(opts);
        shared_ptr<Evaluator> h_eval = opts.get<shared_ptr<Evaluator>>("eval");
        options_copy.set(
            "open",
            create_alternating_open_list_factory(
                h_eval, opts.get<int>("w"),
                opts.get<utils::Verbosity>("verbosity")));
        options_copy.set("f_eval", h_eval);
        vector<shared_ptr<Evaluator>> preferred_list;
        options_copy.set("preferred", preferred_list);

        return plugins::make_shared_from_arg_tuples<eager_search::EagerSearch>(
            options_copy.get<shared_ptr<OpenListFactory>>("open"),
            options_copy.get<bool>("reopen_closed"),
            options_copy.get<shared_ptr<Evaluator>>("f_eval", nullptr),
            options_copy.get_list<shared_ptr<Evaluator>>("preferred"),
            eager_search::get_eager_search_arguments_from_options(
                options_copy));
    }
};

static plugins::FeaturePlugin<AlternatingAStarWAStarSearchFeature> _plugin;
}
