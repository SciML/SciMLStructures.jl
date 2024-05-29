hasportion(::Tunable, ::AbstractArray) = true
hasportion(::Constants, ::AbstractArray) = false
hasportion(::Caches, ::AbstractArray) = false
hasportion(::Discrete, ::AbstractArray) = false

struct ArrayRepack{T}
    sz::T
end
function (f::ArrayRepack)(A)
    @assert length(A) == prod(f.sz)
    reshape(A, f.sz)
end

canonicalize(::Tunable, p::AbstractArray) = vec(p), ArrayRepack(size(p)), true
canonicalize(::Constants, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Caches, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Discrete, p::AbstractArray) = nothing, nothing, nothing

isscimlstructure(::AbstractArray) = true
