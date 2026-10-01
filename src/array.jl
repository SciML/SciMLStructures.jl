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
    if !has_trivial_array_constructor(typeof(f.x), A)
        throw_array_repack_unsupported(typeof(f.x))
    end
    # Only 1-D offset vectors keep offset axes under `vec` and DimensionMismatch
    # inside ArrayInterface.restructure. N-d OffsetArrays vec to a 1-based reshape
    # and already round-trip on main — do not reject them here.
    if f.x isa AbstractVector && Base.has_offset_axes(f.x)
        throw_array_repack_unsupported(typeof(f.x))
    end
    return restructure(f.x, A)
end

function throw_array_repack_unsupported(T)
    error("The original type $T does not support the SciMLStructures interface via the AbstractArray `repack` rules. No method exists to take in a regular array and construct the parent type back. Please define the SciMLStructures interface for this type.")
end

canonicalize(::Tunable, p::AbstractArray) = vec(p), ArrayRepack(p), true
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
