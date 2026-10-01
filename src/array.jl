hasportion(::Tunable, ::AbstractArray) = true
hasportion(::Constants, ::AbstractArray) = false
hasportion(::Caches, ::AbstractArray) = false
hasportion(::Discrete, ::AbstractArray) = false
hasportion(::Initials, ::AbstractArray) = false
hasportion(::Input, ::AbstractArray) = false

struct ArrayRepack{T}
    x::T
end
function (f::ArrayRepack)(A)
    @assert length(A) == prod(size(f.x))
    return if has_trivial_array_constructor(typeof(f.x), A)
        restructure(f.x, A)
    else
        throw_array_repack_unsupported(typeof(f.x))
    end
end

function throw_array_repack_unsupported(T)
    error("The original type $T does not support the SciMLStructures interface via the AbstractArray `repack` rules. No method exists to take in a regular array and construct the parent type back. Please define the SciMLStructures interface for this type.")
end

function supports_array_repack(p::AbstractArray, values)
    has_trivial_array_constructor(typeof(p), values) || return false
    # ArrayInterface.restructure assigns with `vec(out) .= vec(values)`, which
    # fails for non-1-based axes (e.g. OffsetArrays). Allow Base.OneTo and
    # StaticArrays.SOneTo (both start at 1).
    for ax in axes(p)
        first(ax) == 1 || return false
    end
    return true
end

function canonicalize(::Tunable, p::AbstractArray)
    vals = vec(p)
    # Probe with a dense Vector: ArrayRepack is invoked with caller-supplied
    # replacement values (typically `Vector`), and
    # `has_trivial_array_constructor(SubArray, SubArray)` is true while
    # `has_trivial_array_constructor(SubArray, Vector)` is not.
    probe = vals isa Vector ? vals : Vector{eltype(vals)}()
    supports_array_repack(p, probe) || throw_array_repack_unsupported(typeof(p))
    return vals, ArrayRepack(p), true
end
canonicalize(::Constants, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Caches, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Discrete, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Initials, p::AbstractArray) = nothing, nothing, nothing
canonicalize(::Input, p::AbstractArray) = nothing, nothing, nothing

isscimlstructure(::AbstractArray) = false
isscimlstructure(::AbstractArray{<:Number}) = true

function replace(::Tunable, arr::AbstractArray, new_arr::AbstractArray)
    return restructure(arr, new_arr)
end
