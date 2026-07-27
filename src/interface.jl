"""
    isscimlstructure(p)::Bool

Return whether `p` implements the SciMLStructures interface.

# Arguments

  - `p`: The value to classify.

# Interface

The fallback returns `false`. A custom container opts in by defining
`isscimlstructure(::MyType) = true`, then implementing the portion methods it supports.
`AbstractArray{<:Number}` opts in through built-in methods.

An opted-in type must define [`hasportion`](@ref) for every supported
[`AbstractPortion`](@ref). For each present portion, it must also define
[`canonicalize`](@ref) and [`replace`](@ref), and define [`replace!`](@ref) when
[`ismutablescimlstructure`](@ref) is `true`.

# Examples

```jldoctest
julia> using SciMLStructures

julia> SciMLStructures.isscimlstructure([1.0, 2.0])
true
```
"""
isscimlstructure(p) = false

"""
    ismutablescimlstructure(p)::Bool

Return whether `p` supports in-place replacement for its implemented portions.

# Arguments

  - `p`: A SciML structure value.

# Interface

Define `ismutablescimlstructure(::MyType) = true` only when
[`replace!`](@ref) is implemented for every portion reported by [`hasportion`](@ref).
This trait describes the SciMLStructures replacement contract, rather than merely
whether the Julia type is mutable. Define it as `false` for opted-in types that do not
support in-place replacement.
"""
function ismutablescimlstructure end

"""
    hasportion(::AbstractPortion, p)::Bool

Return whether `p` contains the requested SciML structure `portion`.

# Arguments

  - `portion`: A tag such as [`Tunable`](@ref), [`Constants`](@ref), or [`Caches`](@ref).
  - `p`: A SciML structure value.

# Interface

Implement this for every supported `AbstractPortion` and return `false` for absent
portions. An absent portion must have `canonicalize(portion, p) == (nothing, nothing,
nothing)`.
"""
function hasportion end

"""
    canonicalize(::AbstractPortion, p::T1) -> values::T2, repack, aliases::Bool

Convert one `portion` of `p` to its canonical vector representation.

# Arguments

  - `portion`: The requested [`AbstractPortion`](@ref).
  - `p`: A SciML structure value.

# Returns

A three-tuple `(values, repack, aliases)`:

  - `values`: The canonical vector representation, or `nothing` when the portion is absent.
  - `repack`: A callable accepting values in the same ordering and returning a new value
    of `typeof(p)`, or `nothing` when the portion is absent.
  - `aliases`: Whether mutating `values` may mutate `p`, or `nothing` when the portion
    is absent.

# Interface

Implement this for each portion where [`hasportion`](@ref) returns `true`. `values` must
be an `AbstractVector`; flatten multidimensional values in a stable ordering. `repack`
and [`replace`](@ref) must interpret replacement values in that same ordering. The
defined portions are:

  - Tunable: the tunable values/parameters, i.e. the values of the structure which are supposed to be considered
    non-constant when used in the context of an inverse problem solve. For example, this is the set of
    parameters to be optimized during a parameter estimation of an ODE.

      + Tunable parameters are expected to return an `AbstractVector` of unitless values.
      + Tunable parameters are expected to be constant during the solution of the ODE.

  - Constants: the values which are to be considered constant by the solver, i.e. values which are not estimated
    in an inverse problem and which are unchanged in any operation by the user as part of the solver's usage.
  - Caches: the stored cache values of the struct, i.e. the values of the structure which are used as intermediates
    within other computations in order to avoid extra allocations.
  - Discrete: the discrete portions of the state captured inside of the structure. For example, discrete values
    stored outside of the `u` in the parameters to be modified in the callbacks of an ODE.

      + Any parameter that is modified inside of callbacks should be considered Discrete.

## Definitions for Base Objects

  - `Vector`: returns an aliased version of itself as `Tunable`, and an empty vector matching type for `Constants`,
    `Caches`, and `Discrete`.
  - `Array`: returns the `vec(p)` aliased version of itself as `Tunable`, and an empty vector matching type for `Constants`,
    `Caches`, and `Discrete`.
"""
function canonicalize end

"""
    replace(::AbstractPortion, p::T1, new_values) -> p::T1

Return a copy of `p` with one `portion` replaced by `new_values`.

# Arguments

  - `portion`: The portion to replace.
  - `p`: A SciML structure value.
  - `new_values`: Values in the ordering returned by `canonicalize(portion, p)`.

# Interface

This must be observationally equivalent to `canonicalize(portion, p)[2](new_values)`.
Implementations may avoid intermediate canonical buffers.
"""
function replace end

"""
    replace!(::AbstractPortion, p::T1, new_values)::Nothing

Replace one `portion` of `p` in place with `new_values`.

# Arguments

  - `portion`: The portion to replace.
  - `p`: A mutable SciML structure value.
  - `new_values`: Values in the ordering returned by `canonicalize(portion, p)`.

# Interface

Define this only when [`ismutablescimlstructure`](@ref) returns `true`. It must mutate
`p`, return `nothing`, and produce the same resulting values as [`replace`](@ref).
"""
function replace! end

"""
    AbstractPortion

Abstract supertype for tags that identify independently handled portions of a
SciML structure.

# Interface

Use the built-in portion tags whenever their semantics apply. A package may define a
subtype only for a distinct, domain-level portion that consumers explicitly support.
For a custom `P <: AbstractPortion`, a structure that supports `P()` must define
[`hasportion`](@ref), [`canonicalize`](@ref), and [`replace`](@ref) for it, plus
[`replace!`](@ref) when it reports [`ismutablescimlstructure`](@ref) as `true`.
Absent portions must satisfy the `hasportion`/`canonicalize` absence rule.
"""
abstract type AbstractPortion end

"""
    Tunable()

Tag for the tunable portion of a SciML structure.

# Interface

This portion contains values optimized or differentiated with respect to by SciML
estimation tools. [`canonicalize`](@ref) must return an `AbstractVector` of unitless
values in a stable ordering. These values are expected to remain constant while a
solver advances a solution.
"""
struct Tunable <: AbstractPortion end

"""
    Constants()

Tag for the constant portion of a SciML structure.

# Interface

This portion contains values that are neither estimated nor modified as part of the
solver's normal operation. It may contain values that are not suitable for the
[`Tunable`](@ref) vector representation.
"""
struct Constants <: AbstractPortion end

"""
    Caches()

Tag for the cache portion of a SciML structure.

# Interface

This portion contains mutable intermediate storage used to avoid allocations in model
evaluation. A cache must not depend on a value written by an earlier model evaluation;
each evaluation using a cache must initialize every value it reads.

Cache values should be mutable. For automatic-differentiation-compatible caches, use
PreallocationTools.jl.

See [PreallocationTools.jl](https://docs.sciml.ai/PreallocationTools/stable/).
"""
struct Caches <: AbstractPortion end

"""
    Discrete()

Tag for the discrete portion of a SciML structure.

# Interface

This portion contains values outside the primary state that callbacks or other discrete
events may change during a solve. Any parameter mutated from a callback belongs here.
"""
struct Discrete <: AbstractPortion end

"""
    Input()

Tag for the external-input portion of a SciML structure.

# Interface

Use this portion for externally supplied inputs to the modeled system. It is distinct
from [`Tunable`](@ref), [`Constants`](@ref), and solver-maintained [`Caches`](@ref).
"""
struct Input <: AbstractPortion end

"""
    Initials()

Tag for parameters used solely during initialization.

# Interface

This portion contains floating-point values that support automatic differentiation and
are consumed only while constructing or initializing a problem, not while advancing
its solution.
"""
struct Initials <: AbstractPortion end
