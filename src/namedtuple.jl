isscimlstructure(::NamedTuple) = true

hasportion(::Tunable, ::NamedTuple) = true
hasportion(::Constants, ::NamedTuple) = false
hasportion(::Caches, ::NamedTuple) = false
hasportion(::Discrete, ::NamedTuple) = false

struct NTRepack{NT}
    nt::NT
end

function (re::NTRepack)(x::AbstractVector)
    start_idx = 1
    stop_idx = 0
    Functors.fmap(re.nt) do v
        start_idx = stop_idx + 1
        stop_idx += length(v)
        SciMLStructures.replace(SciMLStructures.Tunable(), v, @view x[start_idx:stop_idx])
    end
end

function canonicalize(::Tunable, nt::NamedTuple)
    nt, NTRepack(nt), false
end

canonicalize(::Constants, p::NamedTuple) = nothing, nothing, nothing
canonicalize(::Caches, p::NamedTuple) = nothing, nothing, nothing
canonicalize(::Discrete, p::NamedTuple) = nothing, nothing, nothing

