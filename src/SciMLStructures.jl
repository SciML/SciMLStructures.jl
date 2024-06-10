module SciMLStructures

import Functors
using DataStructures: OrderedDict

include("interface.jl")
include("array.jl")
include("namedtuple.jl")

# public isscimlstructure, ismutablescimlstructure, hasportion, canonicalize,
#        replace, replace!, Tunable, Constants, Caches, Discrete

end
