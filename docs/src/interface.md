# SciMLStructures Interface

SciMLStructures provides a contract for non-state values that SciML solvers,
optimization tools, and sensitivity analysis can inspect and replace generically. The
full tutorial shows a concrete implementation in the [example](example.md).

## Opting In

Implement `isscimlstructure(::MyType) = true` to opt a container into the interface.
For every supported portion tag, implement the public generic functions:

```julia
SciMLStructures.hasportion(::SciMLStructures.AbstractPortion, p)::Bool
SciMLStructures.canonicalize(::SciMLStructures.AbstractPortion, p)
SciMLStructures.replace(::SciMLStructures.AbstractPortion, p, new_values)
```

`hasportion(portion, p)` determines whether the portion is present. When it is
present, `canonicalize` returns `(values, repack, aliases)`, where `values` is an
`AbstractVector`, `repack(new_values)` returns a new container with the values
replaced, and `aliases` states whether mutation of `values` can mutate `p`.
Multidimensional values must be flattened in a stable ordering. `replace` must use
the same ordering and be observationally equivalent to `repack(new_values)`.

When a portion is absent, `hasportion` returns `false` and `canonicalize` must return
`(nothing, nothing, nothing)`. Do not report a portion as present without providing
the corresponding `canonicalize` and `replace` methods.

For types that support in-place replacement, define
`ismutablescimlstructure(::MyType) = true` and implement `replace!` for every
present portion. `replace!` must mutate the original container, return `nothing`, and
produce the same values as `replace`. Define the trait as `false` for an opted-in
type that does not support in-place replacement. The trait is about this replacement
contract, not Julia's `ismutabletype` property.

## Portion Tags

The built-in tags have fixed semantics:

  - [`SciMLStructures.Tunable`](@ref): unitless values optimized or differentiated with respect to.
    They must remain constant while a solver advances a solution.
  - [`SciMLStructures.Constants`](@ref): values that are not estimated or changed by ordinary solver
    operation.
  - [`SciMLStructures.Caches`](@ref): mutable intermediate storage. Every model evaluation must write
    every cache value it reads; cache contents cannot depend on an earlier evaluation.
  - [`SciMLStructures.Discrete`](@ref): values outside the primary state that callbacks or discrete
    events may modify during a solve.
  - [`SciMLStructures.Input`](@ref): externally supplied system inputs.
  - [`SciMLStructures.Initials`](@ref): automatic-differentiation-compatible floating-point values
    used only while constructing or initializing a problem.

Prefer these tags when their semantics apply. Define a subtype of
[`SciMLStructures.AbstractPortion`](@ref) only for a distinct, domain-level portion that downstream
consumers explicitly understand, and apply the same `hasportion`, `canonicalize`,
`replace`, and conditional `replace!` contract to it.

## Built-In Arrays

`AbstractArray{<:Number}` is an opted-in SciML structure. Its [`SciMLStructures.Tunable`](@ref)
portion is `vec(p)` and aliases the original array; every other built-in portion is
absent. `replace(Tunable(), p, values)` reconstructs an array compatible with `p`'s
array type and shape.
