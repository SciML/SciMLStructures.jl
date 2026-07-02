module SciMLStructures

using ArrayInterface: has_trivial_array_constructor, restructure

include("interface.jl")
include("array.jl")

# The SciMLStructures interface is consumed via qualified access
# (`SciMLStructures.canonicalize`, `SciMLStructures.Tunable`, ...) rather than
# `export`, so mark the intended public surface with the `public` keyword on
# Julia 1.11+ (`public` is a parse error on older releases, hence the guard).
@static if VERSION >= v"1.11"
    eval(
        Expr(
            :public,
            :isscimlstructure, :ismutablescimlstructure, :hasportion, :canonicalize,
            :replace, :replace!, :AbstractPortion, :Tunable, :Constants, :Caches,
            :Discrete, :Initials, :Input
        )
    )
end

include("precompilation.jl")

end
