"""
    isscimlstructure(p)::Bool

Return whether `p` satisfies the SciMLStructures interface.

The default is `false`; types opt in by defining `isscimlstructure(::MyType) = true`.
`AbstractArray{<:Number}` is treated as a SciMLStructure by built-in methods.
"""
isscimlstructure(p) = false

"""
    ismutablescimlstructure(p)::Bool

Return whether `p` supports the mutating SciMLStructures interface.

This is not mutability in the sense of the Julia type. It means the structure supports
in-place `AbstractPortion` replacement through [`replace!`](@ref).
"""
function ismutablescimlstructure end

"""
    hasportion(::AbstractPortion, p)::Bool

Denotes whether a portion is used in a given definition of a SciMLStructure. If `false`,
then it's expected that the canonical values are `nothing`.
"""
function hasportion end

"""
    canonicalize(::AbstractPortion, p::T1) -> values::T2, repack, aliases::Bool

The core function of the interface is the `canonicalize` function. `canonicalize` allows the user to define
to the solver how to represent the given "portion" in a standard `AbstractVector` type which allows for
interfacing with standard tools like linear algebra in an efficient manner. The type of portions which
are defined are:

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

Equivalent to `canonicalize(::AbstractPortion, p::T1)[2](new_values)`, though allowed to
optimize and not construct intermediates. For more information on the arguments, see
canonicalize.
"""
function replace end

"""
    replace!(::AbstractPortion, p::T1, new_values)::Nothing

Equivalent to `canonicalize(::AbstractPortion, p::T1)[2](new_values)`, though done in a mutating
fashion and is allowed to optimize and not construct intermediates. Requires a mutable
SciMLStructure. For more information on the arguments, see canonicalize.
"""
function replace! end

"""
    AbstractPortion

An abstract portion tag used in the SciMLStructures.jl interfaces, i.e.
`canonicalize(::AbstractPortion, p::T1)` or `replace!(::AbstractPortion, p::T1)`.
"""
abstract type AbstractPortion end

"""
    Tunable()

The tunable portion of the SciMLStructure, i.e. the parameters which are meant to be optimized.
"""
struct Tunable <: AbstractPortion end

"""
    Constants()

The constant portion of the SciMLStructure, i.e. the parameters which are meant to be
constant with respect to optimization.
"""
struct Constants <: AbstractPortion end

"""
    Caches()

The caches portion of the SciMLStructure, i.e. the caches which are meant to allow for
writing the model function without allocations.

Rules for caches:

  - Caches should be a mutable object.
  - Caches should not assume any previous value in them. All values within the cache should be
    written into in the `f` call that they are used from.

For making caches compatible with automatic differentiation, see
[PreallocationTools.jl](https://docs.sciml.ai/PreallocationTools/stable/).
"""
struct Caches <: AbstractPortion end

"""
    Discrete()

The discrete portion of the SciMLStructure.
"""
struct Discrete <: AbstractPortion end

"""
    Input()

The inputs portion of the SciMLStructure.
"""
struct Input <: AbstractPortion end

"""
    Initials()

The portion of the SciMLStructure used for parameters solely involved in initialization.
These should be floating point numbers supporting automatic differentiation.
"""
struct Initials <: AbstractPortion end
