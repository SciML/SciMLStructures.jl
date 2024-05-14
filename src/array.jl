hasportion(::Tunable, ::Array) = true
hasportion(::Constants, ::Array) = false
hasportion(::Caches, ::Array) = false
hasportion(::Discrete, ::Array) = false

struct ArrayRepack{T}
    sz::T
end
function (f::ArrayRepack)(A)
    @assert length(A) == prod(f.sz)
    reshape(A, f.sz)
end

canonicalize(::Tunable, p::Array) = vec(p), ArrayRepack(size(p)), true
canonicalize(::Constants, p::Array) = nothing, nothing, nothing
canonicalize(::Caches, p::Array) = nothing, nothing, nothing
canonicalize(::Discrete, p::Array) = nothing, nothing, nothing

isscimlstructure(::Array) = true
