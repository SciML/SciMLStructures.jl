using SciMLStructures, BenchmarkTools
using StableRNGs

const SUITE = BenchmarkGroup()
const rng = StableRNG(123)

const SS = SciMLStructures

# =============================================================================
# canonicalize / replace on arrays
# =============================================================================

SUITE["canonicalize"] = BenchmarkGroup()

vec = rand(rng, 1000)
mat = rand(rng, 50, 50)

SUITE["canonicalize"]["vector_tunable"] = @benchmarkable SS.canonicalize(
    SS.Tunable(), $vec
)
SUITE["canonicalize"]["matrix_tunable"] = @benchmarkable SS.canonicalize(
    SS.Tunable(), $mat
)
SUITE["canonicalize"]["vector_caches"] = @benchmarkable SS.canonicalize(
    SS.Caches(), $vec
)
SUITE["canonicalize"]["vector_constants"] = @benchmarkable SS.canonicalize(
    SS.Constants(), $vec
)

vals, repack = SS.canonicalize(SS.Tunable(), vec)
new_vals = vals .* 1.01
mat_vals, = SS.canonicalize(SS.Tunable(), mat)
new_mat_vals = mat_vals .* 1.01

SUITE["replace"] = BenchmarkGroup()
SUITE["replace"]["repack"] = @benchmarkable $repack($new_vals)
SUITE["replace"]["replace_vector"] = @benchmarkable SS.replace(
    SS.Tunable(), $vec, $new_vals
)
SUITE["replace"]["replace_matrix"] = @benchmarkable SS.replace(
    SS.Tunable(), $mat, $new_mat_vals
)
