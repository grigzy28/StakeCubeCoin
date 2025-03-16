
#include <chainparams.h>


class CChainParams2 : public CChainParams
{
public:

	const Consensus::Params& GetConsensus2() const { return consensus2; }
	
	Consensus::Params consensus2;
};

const CChainParams2 &Params2();
