// Copyright (c) 2016 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <validation.h>
#include <versionbits.h>
#include <consensus/params.h>
#include <logging.h>
#include <util/translation.h>

std::atomic<bool> preloadedchain{false};


static int calculateStartHeight(const CBlockIndex* pindexPrev, ThresholdState state, const int nPeriod, const ThresholdConditionCache& cache) {
    int nStartHeight{std::numeric_limits<int>::max()};

    // we are interested only in state STARTED
    // For state DEFINED: it is not started yet, nothing to do
    // For states LOCKED_IN, FAILED, ACTIVE: it is too late, nothing to do
    while (state == ThresholdState::STARTED) {
        nStartHeight = std::min(pindexPrev->nHeight + 1, nStartHeight);

        // we can walk back here because the only way for STARTED state to exist
        // in cache already is to be calculated in previous runs via "walk forward"
        // loop below starting from DEFINED state.
        pindexPrev = pindexPrev->GetAncestor(pindexPrev->nHeight - nPeriod);
        auto cache_it = cache.find(pindexPrev);
        assert(cache_it != cache.end());

        state = cache_it->second;
    }

    return nStartHeight;
}

ThresholdState AbstractThresholdConditionChecker::GetStateFor(const CBlockIndex* pindexPrev, const Consensus::Params& params, ThresholdConditionCache& cache) const
{
    int nPeriod = Period(params);
    int64_t nTimeStart = BeginTime(params);
    int64_t nTimeTimeout = EndTime(params);
    int min_activation_height = MinActivationHeight(params);


//	LogPrint(BCLog::BENCHMARK, "period: %s\n", nPeriod);

    // A block's state is always the same as that of the first of its period, so it is computed based on a pindexPrev whose height equals a multiple of nPeriod - 1.
    if (pindexPrev != nullptr) {
        pindexPrev = pindexPrev->GetAncestor(pindexPrev->nHeight - ((pindexPrev->nHeight + 1) % nPeriod));
    }

    // Walk backwards in steps of nPeriod to find a pindexPrev whose information is known
    std::vector<const CBlockIndex*> vToCompute;
    while (cache.count(pindexPrev) == 0) {
        if (pindexPrev == nullptr) {
            // The genesis block is by definition defined.
            cache[pindexPrev] = ThresholdState::DEFINED;
            break;
        }
        if (pindexPrev->GetMedianTimePast() < nTimeStart) {
            // Optimization: don't recompute down further, as we know every earlier block will be before the start time
            cache[pindexPrev] = ThresholdState::DEFINED;
            break;
        }
        vToCompute.push_back(pindexPrev);
        pindexPrev = pindexPrev->GetAncestor(pindexPrev->nHeight - nPeriod);
    }

    // At this point, cache[pindexPrev] is known
    assert(cache.count(pindexPrev));
    ThresholdState state = cache[pindexPrev];

//    int nStartHeight{std::numeric_limits<int>::max()};
    int nStartHeight = calculateStartHeight(pindexPrev, state, nPeriod, cache);

/*
    for (const auto& pair : cache) {
        if (pair.second == ThresholdState::STARTED && nStartHeight > pair.first->nHeight + 1) {
            nStartHeight = pair.first->nHeight + 1;
        }
    }
*/

//	LogPrint(BCLog::BENCHMARK, "StartHeight: %s\n", nStartHeight);

    // Now walk forward and compute the state of descendants of pindexPrev
    while (!vToCompute.empty()) {
        ThresholdState stateNext = state;
        pindexPrev = vToCompute.back();
        vToCompute.pop_back();

        switch (state) {
            case ThresholdState::DEFINED: {
                if (pindexPrev->GetMedianTimePast() >= nTimeTimeout) {
                    stateNext = ThresholdState::FAILED;
                } else if (pindexPrev->GetMedianTimePast() >= nTimeStart) {
                    stateNext = ThresholdState::STARTED;
                    nStartHeight = pindexPrev->nHeight + 1;
                }
                break;
            }
            case ThresholdState::STARTED: {
                if (pindexPrev->GetMedianTimePast() >= nTimeTimeout) {
                    stateNext = ThresholdState::FAILED;
                    break;
                }

                // We need to count
                const CBlockIndex* pindexCount = pindexPrev;
                int count = 0;

                int nAttempt = (pindexCount->nHeight + 1 - nStartHeight) / nPeriod;
				        int nThreshold = Threshold(params, nAttempt);

                for (int i = 0; i < nPeriod; i++) {
                    if (Condition(pindexCount, params)) {
                        count++;
                    }
                    if (count >= nThreshold) {
                        stateNext = ThresholdState::LOCKED_IN;
                        break;
                    }
                    pindexCount = pindexCount->pprev;
                }

                assert(nStartHeight > 0 && nStartHeight < std::numeric_limits<int>::max());
                if (count >= nThreshold) {
                    stateNext = ThresholdState::LOCKED_IN;
                } else if (pindexPrev->GetMedianTimePast() >= nTimeTimeout) {
                    stateNext = ThresholdState::FAILED;
                }
                break;
            }
            case ThresholdState::LOCKED_IN: {
                // Always progresses into ACTIVE.
                stateNext = ThresholdState::ACTIVE;

//                if (pindexPrev->nHeight + 1 >= min_activation_height) {
//                    stateNext = ThresholdState::ACTIVE;
//                }

                break;
            }
            case ThresholdState::FAILED:
            case ThresholdState::ACTIVE: {
                // Nothing happens, these are terminal states.
                break;
            }
        }
        cache[pindexPrev] = state = stateNext;
    }

    return state;
}

ThresholdState AbstractThresholdConditionChecker::GetStateForBuildCache(const CBlockIndex* pindexPrev, const Consensus::Params& params, ThresholdConditionCache& cache, int bitIn) const
{

    int64_t nTimeStart = BeginTime(params);

    // Walk backwards in steps of nPeriod to find a pindexPrev whose information is known
    std::vector<const CBlockIndex*> vToCompute;
	int maxtip = pindexPrev->nHeight;

    while (cache.count(pindexPrev) == 0) {
        if (pindexPrev == nullptr) {
            // The genesis block is by definition defined.
            cache[pindexPrev] = ThresholdState::DEFINED;
            break;
        }
        if (pindexPrev->GetMedianTimePast() < nTimeStart) {
            // Optimization: don't recompute down further, as we know every earlier block will be before the start time
            cache[pindexPrev] = ThresholdState::DEFINED;
            break;
        }
        vToCompute.push_back(pindexPrev);

//		LogPrint(BCLog::BENCHMARK, "First Height: %s\n", pindexPrev->nHeight);

        pindexPrev = pindexPrev->GetAncestor(pindexPrev->nHeight - 1);
    }

//	LogPrint(BCLog::BENCHMARK, "Height: Start\n");
//	LogPrint(BCLog::BENCHMARK, "Height: %s\n", );

    // At this point, cache[pindexPrev] is known
    assert(cache.count(pindexPrev));
    ThresholdState state = cache[pindexPrev];

//	LogPrint(BCLog::BENCHMARK, "Height: %s\n", pindexPrev->nHeight);

	while (!vToCompute.empty()) {
        ThresholdState stateNext = state;
        pindexPrev = vToCompute.back();
        vToCompute.pop_back();

//		LogPrint(BCLog::BENCHMARK, "Second Height: %s - Counter: %s - Bit: %s\n", pindexPrev->nHeight, counter, bitIn);

    cache[pindexPrev] = state = stateNext;


  }

//	LogPrint(BCLog::BENCHMARK, "Height: End\n");

	preloadedchain = true;

	return state;
}

BIP9Stats AbstractThresholdConditionChecker::GetStateStatisticsFor(const CBlockIndex* pindex, const Consensus::Params& params, ThresholdConditionCache& cache) const
{
    BIP9Stats stats = {};

    stats.period = Period(params);
    stats.threshold = Threshold(params, 0);

    if (pindex == nullptr)
        return stats;

    // Find beginning of period
    const CBlockIndex* pindexEndOfPrevPeriod = pindex->GetAncestor(pindex->nHeight - ((pindex->nHeight + 1) % stats.period));
    stats.elapsed = pindex->nHeight - pindexEndOfPrevPeriod->nHeight;

    // Re-calculate current threshold
    int nAttempt{0};
    const ThresholdState state = GetStateFor(pindexEndOfPrevPeriod, params, cache);
    if (state == ThresholdState::STARTED) {
        int nStartHeight = GetStateSinceHeightFor(pindexEndOfPrevPeriod, params, cache);
        nAttempt = (pindexEndOfPrevPeriod->nHeight + 1 - nStartHeight)/stats.period;
    }
    stats.threshold = Threshold(params, nAttempt);

    // Count from current block to beginning of period
    int count = 0;
    const CBlockIndex* currentIndex = pindex;
    while (pindexEndOfPrevPeriod->nHeight != currentIndex->nHeight){
        if (Condition(currentIndex, params))
            count++;
        currentIndex = currentIndex->pprev;
    }

    stats.count = count;
    stats.possible = (stats.period - stats.threshold ) >= (stats.elapsed - count);

    return stats;
}

int AbstractThresholdConditionChecker::GetStateSinceHeightFor(const CBlockIndex* pindexPrev, const Consensus::Params& params, ThresholdConditionCache& cache) const
{
    const ThresholdState initialState = GetStateFor(pindexPrev, params, cache);

    // BIP 9 about state DEFINED: "The genesis block is by definition in this state for each deployment."
    if (initialState == ThresholdState::DEFINED) {
        return 0;
    }

    const int nPeriod = Period(params);

    // A block's state is always the same as that of the first of its period, so it is computed based on a pindexPrev whose height equals a multiple of nPeriod - 1.
    // To ease understanding of the following height calculation, it helps to remember that
    // right now pindexPrev points to the block prior to the block that we are computing for, thus:
    // if we are computing for the last block of a period, then pindexPrev points to the second to last block of the period, and
    // if we are computing for the first block of a period, then pindexPrev points to the last block of the previous period.
    // The parent of the genesis block is represented by nullptr.
    pindexPrev = pindexPrev->GetAncestor(pindexPrev->nHeight - ((pindexPrev->nHeight + 1) % nPeriod));

    const CBlockIndex* previousPeriodParent = pindexPrev->GetAncestor(pindexPrev->nHeight - nPeriod);

    while (previousPeriodParent != nullptr && GetStateFor(previousPeriodParent, params, cache) == initialState) {
        pindexPrev = previousPeriodParent;
        previousPeriodParent = pindexPrev->GetAncestor(pindexPrev->nHeight - nPeriod);
    }

    // Adjust the result because right now we point to the parent block.
    return pindexPrev->nHeight + 1;
}

namespace
{
/**
 * Class to implement versionbits logic.
 */
class VersionBitsConditionChecker : public AbstractThresholdConditionChecker {
private:
    const Consensus::DeploymentPos id;

protected:
    int64_t BeginTime(const Consensus::Params& params) const override { return params.vDeployments[id].nStartTime; }
    int64_t EndTime(const Consensus::Params& params) const override { return params.vDeployments[id].nTimeout; }
    int Period(const Consensus::Params& params) const override { return params.vDeployments[id].nWindowSize ? params.vDeployments[id].nWindowSize : params.nMinerConfirmationWindow; }

    int Threshold(const Consensus::Params& params, int nAttempt) const override
    {
        if (params.vDeployments[id].nThresholdStart == 0) {
            return params.nRuleChangeActivationThreshold;
        }
        if (params.vDeployments[id].nThresholdMin == 0 || params.vDeployments[id].nFalloffCoeff == 0) {
            return params.vDeployments[id].nThresholdStart;
        }
        int64_t nThresholdCalc = params.vDeployments[id].nThresholdStart - nAttempt * nAttempt * Period(params) / 100 / params.vDeployments[id].nFalloffCoeff;
        return std::max(params.vDeployments[id].nThresholdMin, nThresholdCalc);
    }

    bool Condition(const CBlockIndex* pindex, const Consensus::Params& params) const override
    {
        return (((pindex->nVersion & VERSIONBITS_TOP_MASK) == VERSIONBITS_TOP_BITS) && (pindex->nVersion & Mask(params)) != 0);
    }

public:
    explicit VersionBitsConditionChecker(Consensus::DeploymentPos id_) : id(id_) {}
    uint32_t Mask(const Consensus::Params& params) const { return ((uint32_t)1) << params.vDeployments[id].bit; }
};

} // namespace

ThresholdState VersionBitsState(const CBlockIndex* pindexPrev, const Consensus::Params& params, Consensus::DeploymentPos pos, VersionBitsCache& cache)
{
    return VersionBitsConditionChecker(pos).GetStateFor(pindexPrev, params, cache.caches[pos]);
}

BIP9Stats VersionBitsStatistics(const CBlockIndex* pindexPrev, const Consensus::Params& params, Consensus::DeploymentPos pos, VersionBitsCache& cache)
{
    return VersionBitsConditionChecker(pos).GetStateStatisticsFor(pindexPrev, params, cache.caches[pos]);
}

int VersionBitsStateSinceHeight(const CBlockIndex* pindexPrev, const Consensus::Params& params, Consensus::DeploymentPos pos, VersionBitsCache& cache)
{
    return VersionBitsConditionChecker(pos).GetStateSinceHeightFor(pindexPrev, params, cache.caches[pos]);
}

uint32_t VersionBitsMask(const Consensus::Params& params, Consensus::DeploymentPos pos)
{
    return VersionBitsConditionChecker(pos).Mask(params);
}

static const VersionBitsConditionChecker checker_CSV(Consensus::DEPLOYMENT_CSV);
static const VersionBitsConditionChecker checker_DIP0001(Consensus::DEPLOYMENT_DIP0001);
static const VersionBitsConditionChecker checker_BIP147(Consensus::DEPLOYMENT_BIP147);
static const VersionBitsConditionChecker checker_DIP0003(Consensus::DEPLOYMENT_DIP0003);
static const VersionBitsConditionChecker checker_DIP0008(Consensus::DEPLOYMENT_DIP0008);
static const VersionBitsConditionChecker checker_DIP0020(Consensus::DEPLOYMENT_DIP0020);
static const VersionBitsConditionChecker checker_GOV_FEE(Consensus::DEPLOYMENT_GOV_FEE);

const std::vector<const AbstractThresholdConditionChecker*> versionbitsCheckers = {
    &checker_DIP0001,
    &checker_BIP147,
    &checker_DIP0003,
    &checker_DIP0008,
    &checker_DIP0020,
    &checker_GOV_FEE,
};

void VersionBitsCache::InitializeAsync(const CBlockIndex* pindexPrev, const Consensus::Params& params)
{
    if (preloadedchain.load()) return;

    vbworkerPool.resize(1);
//    vbworkerPool.stop(false);

    vbworkerPool.push([pindexPrev, params](int) {
//        LogPrintf("inside versionbits preload (last 100 blocks)\n");

        constexpr int maxDepth = 100;
        std::string warningMessages;

        for (int bit = 0; bit < Consensus::MAX_VERSION_BITS_DEPLOYMENTS; ++bit) {
            const CBlockIndex* pindex = pindexPrev;
      			WarningBitsConditionChecker checker(bit);

			      LogPrint(BCLog::BENCHMARK, "bit: %s build cache\n", bit);

//            if (!preloadedchain && (preloadchaincounter < VERSIONBITS_NUM_BITS)) {
//  	        ThresholdState state = checker.GetStateForBuildCache(pindex, params, warningcache[bit], bit);
        }
        
        for (int bit = 0; bit < Consensus::MAX_VERSION_BITS_DEPLOYMENTS; ++bit) {
//LogPrintf("Preloading bit %d\n", bit);
        	  if (params.vDeployments[bit].bit == -1) continue;
//LogPrintf("Preloading bit %d\n", bit);
//          if (params.vDeployments[bit].bit > 0 || params.vDeployments[bit].bit < 28)
//             continue;
//            WarningBitsConditionChecker checker(static_cast<Consensus::DeploymentPos>(bit));

            const CBlockIndex* pindex = pindexPrev;

            int depth = 0;
            std::vector<const CBlockIndex*> blocksToCompute;

      			WarningBitsConditionChecker checker(bit);

			      LogPrint(BCLog::BENCHMARK, "bit: %s\n", bit);

//            if (!preloadedchain && (preloadchaincounter < VERSIONBITS_NUM_BITS)) {
  	        ThresholdState state = checker.GetStateForBuildCache(pindex, params, warningcache[bit], bit);
//            ThresholdState state = checker.GetStateFor(pindex, params, warningcache[bit]);

			      LogPrint(BCLog::BENCHMARK, "bit: %s\n", bit);

//        				preloadchaincounter = preloadchaincounter + 1;
//				        if (preloadedchain) preloadchaincounter=0;

/*
            if (state == ThresholdState::ACTIVE || state == ThresholdState::LOCKED_IN) {
                const std::string strWarning = strprintf(_("Warning: unknown new rules activated (versionbit %i)").translated, bit);
                if (state == ThresholdState::ACTIVE) {
                    DoWarning(strWarning);
                } else {
                    AppendWarning(warningMessages, strWarning);
                }
            }
*/

//      			}


            while (pindex && depth < maxDepth) {
                {
                    std::lock_guard<std::mutex> lock(mtxCaches[bit]);
                    if (caches[bit].count(pindex)) break; // already cached
                }

                blocksToCompute.push_back(pindex);
                pindex = pindex->pprev;
                depth++;
            }

//            ThresholdState state;

            {
                std::lock_guard<std::mutex> lock(mtxCaches[bit]);
                if (pindex) {
                    state = caches[bit][pindex]; // start from known state
                } else {
                    state = ThresholdState::DEFINED; // fallback
                }
            }

            while (!blocksToCompute.empty()) {
                pindex = blocksToCompute.back();
                blocksToCompute.pop_back();

                // compute next state (simplified — you might need real logic here)
                ThresholdState stateNext = state;

//if (pindex->nVersion) {
//    if (state != ThresholdState::DEFINED) {
        std::lock_guard<std::mutex> lock(mtxCaches[bit]);
        caches[bit][pindex] = state = stateNext;
//    }
//}

            }
//        LogPrintf("bit %d cache size: %zu entries\n", bit, caches[bit].size());
    for (unsigned int d = 0; d < Consensus::MAX_VERSION_BITS_DEPLOYMENTS; d++) {
        caches[d].clear();
        warningcache[d].clear();
    }

        }

        preloadedchain.store(true);

    for (unsigned int d = 0; d < Consensus::MAX_VERSION_BITS_DEPLOYMENTS; d++) {
        caches[d].clear();
        warningcache[d].clear();
    }

    });
}

void VersionBitsCache::Clear()
{
    for (unsigned int d = 0; d < Consensus::MAX_VERSION_BITS_DEPLOYMENTS; d++) {
        caches[d].clear();
    }
}

ThresholdState VersionBitsStateBuildCache(const CBlockIndex* pindexPrev, const Consensus::Params& params, Consensus::DeploymentPos pos, VersionBitsCache& cache)
{
    return VersionBitsConditionChecker(pos).GetStateForBuildCache(pindexPrev, params, cache.caches[pos], pos);
}
