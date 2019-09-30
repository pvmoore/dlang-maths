module maths.random.fastrng;

import maths.all;

const MULT 			= 62089911;
const INV_FLOAT_MAX = 1.0f / 0xffff_ffff;

/**
 * Fast RNG with good distribution (between 0 and 1)
 */
final class FastRNG {
private:
	ulong m_seed;
public:
	this(ulong seed = unpredictableSeed()) {
		m_seed = seed;
	}

	float next() {
		m_seed *= MULT;
		return (m_seed & 0xffff_ffff) * INV_FLOAT_MAX;
	}
}



