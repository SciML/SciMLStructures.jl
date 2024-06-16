module SciMLStructures

import Functors
using DataStructures: OrderedDict
using ArrayInterface: has_trivial_array_constructor

include("interface.jl")
include("array.jl")
include("namedtuple.jl")

# public isscimlstructure, ismutablescimlstructure, hasportion, canonicalize,
#        replace, replace!, Tunable, Constants, Caches, Discrete

end
