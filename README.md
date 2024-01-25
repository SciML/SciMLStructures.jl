# SciMLStructures

[![Join the chat at https://julialang.zulipchat.com #sciml-bridged](https://img.shields.io/static/v1?label=Zulip&message=chat&color=9558b2&labelColor=389826)](https://julialang.zulipchat.com/#narrow/stream/279055-sciml-bridged)
[![Global Docs](https://img.shields.io/badge/docs-SciML-blue.svg)](https://docs.sciml.ai/SciMLStructures/stable/)

[![codecov](https://codecov.io/gh/SciML/SciMLStructures.jl/branch/master/graph/badge.svg?token=FwXaKBNW67)](https://codecov.io/gh/SciML/SciMLStructures.jl)
[![Build Status](https://github.com/SciML/SciMLStructures.jl/workflows/CI/badge.svg)](https://github.com/SciML/SciMLStructures.jl/actions?query=workflow%3ACI)

[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor%27s%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

SciMLStructures.jl defines a generic interface for interacting with solvers, estimation tooling, and more within
the SciML ecosystem and the greater Julia universe. SciMLStructures.jl defines a structured enforcable interface
which allows for solvers to be able to handle custom user types in an efficient and generalized way.

## Core Interface Definitions

### `canonicalize` Definition

```julia
cononicalize(::AbstractPortion, p) -> values::AbstractArray, repack, aliases::Bool
repack(::AbstractArray) -> (Float64[], Int[], Vector{Float64}[])
```

### Portion Defintions

The core function of the interface is the `canonicalize` function. `caonicalize` allows the user to define
to the solver how to represent the given "portion" in a standard `AbstractVector` type which allows for
interfacing with standard tools like linear algebra in an efficient manner. The type of portions which
are defined are:

* Tunable: the tunable values/parameters, i.e. the values of the structure which are supposed to be considered
  non-constant when used in the context of an inverse problem solve. For example, this is the set of
  parameters to be optimized during a parameter estimation of an ODE.
* Constants: the values which are to be considered constant by the solver, i.e. values which are not estimated
  in an inverse problem and which are unchanged in any operation by the user as part of the solver's usage.
* Caches: the stored cache values of the struct, i.e. the values of the structure which are used as intermediates
  within other computations in order to avoid extra allocations.
* Discrete: the discrete portions of the state captured inside of the structure. For example, discrete values
  stored outside of the `u` in the parameters to be modified in the callbacks of an ODE.

## Core Assumptions of the Interface

* `canonicalize` returns an `AbstractVector`
* `canonicalize` returns the unitless values
