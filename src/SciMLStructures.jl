module SciMLStructures

using ArrayInterface: has_trivial_array_constructor, restructure

include("interface.jl")
include("array.jl")
include("precompilation.jl")

# public isscimlstructure, ismutablescimlstructure, hasportion, canonicalize,
#        replace, replace!, Tunable, Constants, Caches, Discrete

end
