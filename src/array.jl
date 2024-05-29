hasportion(::Tunable, ::AbstractArray) = true
hasportion(::Constants, ::AbstractArray) = false
hasportion(::Caches, ::AbstractArray) = false
hasportion(::Discrete, ::AbstractArray) = false

struct ArrayRepack{T, Ty}
    sz::T
    type::Ty
end
function (f::ArrayRepack)(A)
    @assert length(A) == prod(f.sz)
    reshape(convert(f.type, A), f.sz)
end

function canonicalize(::Tunable, p::AbstractArray)
    arr = collect(p)
    vec(arr), ArrayRepack(size(p), typeof(p)), true
end
canonicalize(::Tunable, p::Array) = vec(p), ArrayRepack(size(p), typeof(p)), true
canonicalize(::Constants, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Caches, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Discrete, p::AbstractArray) = nothing, nothing, nothing

isscimlstructure(::AbstractArray) = true
