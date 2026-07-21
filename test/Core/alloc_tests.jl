using SciMLStructures
using SciMLStructures: Tunable, Constants, Caches, Discrete, Initials, Input,
    canonicalize, hasportion, ismutablescimlstructure, isscimlstructure, replace, replace!
using AllocCheck
using Test

# AllocCheck has known false positives on macOS ARM with Julia 1.12+
# See: https://github.com/SciML/SciMLStructures.jl/pull/54
const SKIP_ALLOCCHECK = Sys.isapple() && Sys.ARCH == :aarch64 && VERSION >= v"1.12"

@testset "AllocCheck - Zero Allocations" begin
    @testset "hasportion checks" begin
        arr = rand(10)

        @check_allocs check_hasportion_tunable(a) = hasportion(Tunable(), a)
        @check_allocs check_hasportion_constants(a) = hasportion(Constants(), a)
        @check_allocs check_hasportion_caches(a) = hasportion(Caches(), a)
        @check_allocs check_hasportion_discrete(a) = hasportion(Discrete(), a)
        @check_allocs check_hasportion_initials(a) = hasportion(Initials(), a)
        @check_allocs check_hasportion_input(a) = hasportion(Input(), a)

        if SKIP_ALLOCCHECK
            @test_skip check_hasportion_tunable(arr) == true
            @test_skip check_hasportion_constants(arr) == false
            @test_skip check_hasportion_caches(arr) == false
            @test_skip check_hasportion_discrete(arr) == false
            @test_skip check_hasportion_initials(arr) == false
            @test_skip check_hasportion_input(arr) == false
        else
            @test check_hasportion_tunable(arr) == true
            @test check_hasportion_constants(arr) == false
            @test check_hasportion_caches(arr) == false
            @test check_hasportion_discrete(arr) == false
            @test check_hasportion_initials(arr) == false
            @test check_hasportion_input(arr) == false
        end
    end

    @testset "isscimlstructure checks" begin
        arr = rand(10)
        arr_int = [1, 2, 3]
        arr_any = Any[1, 2, 3]

        @check_allocs check_isscimlstructure(a::Vector{Float64}) = isscimlstructure(a)
        @check_allocs check_isscimlstructure_int(a::Vector{Int}) = isscimlstructure(a)

        if SKIP_ALLOCCHECK
            @test_skip check_isscimlstructure(arr) == true
            @test_skip check_isscimlstructure_int(arr_int) == true
        else
            @test check_isscimlstructure(arr) == true
            @test check_isscimlstructure_int(arr_int) == true
        end
        # This test doesn't use @check_allocs wrapper, so always run it
        @test isscimlstructure(arr_any) == false
    end

    @testset "canonicalize for Vector (aliased, zero alloc)" begin
        arr = rand(10)

        @check_allocs function check_canonicalize_vec(a::Vector{Float64})
            canonicalize(Tunable(), a)
        end

        if SKIP_ALLOCCHECK
            @test_skip begin
                vals, repack, aliases = check_canonicalize_vec(arr)
                vals === arr && aliases == true
            end
        else
            vals, repack, aliases = check_canonicalize_vec(arr)
            @test vals === arr
            @test aliases == true
        end
    end

    @testset "canonicalize returns for other portions" begin
        arr = rand(10)

        @check_allocs check_canon_constants(a::Vector{Float64}) = canonicalize(Constants(), a)
        @check_allocs check_canon_caches(a::Vector{Float64}) = canonicalize(Caches(), a)
        @check_allocs check_canon_discrete(a::Vector{Float64}) = canonicalize(Discrete(), a)
        @check_allocs check_canon_initials(a::Vector{Float64}) = canonicalize(Initials(), a)
        @check_allocs check_canon_input(a::Vector{Float64}) = canonicalize(Input(), a)

        if SKIP_ALLOCCHECK
            @test_skip check_canon_constants(arr) == (nothing, nothing, nothing)
            @test_skip check_canon_caches(arr) == (nothing, nothing, nothing)
            @test_skip check_canon_discrete(arr) == (nothing, nothing, nothing)
            @test_skip check_canon_initials(arr) == (nothing, nothing, nothing)
            @test_skip check_canon_input(arr) == (nothing, nothing, nothing)
        else
            @test check_canon_constants(arr) == (nothing, nothing, nothing)
            @test check_canon_caches(arr) == (nothing, nothing, nothing)
            @test check_canon_discrete(arr) == (nothing, nothing, nothing)
            @test check_canon_initials(arr) == (nothing, nothing, nothing)
            @test check_canon_input(arr) == (nothing, nothing, nothing)
        end
    end
end

@testset "Generic SciMLStructures interface" begin
    mutable struct GenericParameters
        tunables::Vector{Float64}
        constant::Float64
    end

    isscimlstructure(::GenericParameters) = true
    ismutablescimlstructure(::GenericParameters) = true
    hasportion(::Tunable, ::GenericParameters) = true
    hasportion(::Constants, ::GenericParameters) = true
    hasportion(::Union{Caches, Discrete, Initials, Input}, ::GenericParameters) = false

    function canonicalize(::Tunable, p::GenericParameters)
        values = copy(p.tunables)
        repack = values -> GenericParameters(collect(values), p.constant)
        return values, repack, false
    end
    function canonicalize(::Constants, p::GenericParameters)
        values = [p.constant]
        repack = values -> GenericParameters(copy(p.tunables), only(values))
        return values, repack, false
    end
    canonicalize(::Union{Caches, Discrete, Initials, Input}, ::GenericParameters) =
        (nothing, nothing, nothing)

    function replace(::Tunable, p::GenericParameters, values)
        return GenericParameters(collect(values), p.constant)
    end
    function replace(::Constants, p::GenericParameters, values)
        return GenericParameters(copy(p.tunables), only(values))
    end
    function replace!(::Tunable, p::GenericParameters, values)
        copyto!(p.tunables, values)
        return nothing
    end
    function replace!(::Constants, p::GenericParameters, values)
        p.constant = only(values)
        return nothing
    end

    p = GenericParameters([1.0, 2.0], 3.0)
    @test isscimlstructure(p)
    @test ismutablescimlstructure(p)
    @test hasportion(Tunable(), p)
    @test hasportion(Constants(), p)
    for portion in (Caches(), Discrete(), Initials(), Input())
        @test !hasportion(portion, p)
        @test canonicalize(portion, p) == (nothing, nothing, nothing)
    end

    tunables, repack_tunables, aliases = canonicalize(Tunable(), p)
    @test tunables == [1.0, 2.0]
    @test !aliases
    rebuilt_tunables = repack_tunables([4.0, 5.0])
    replaced_tunables = replace(Tunable(), p, [4.0, 5.0])
    @test rebuilt_tunables.tunables == [4.0, 5.0]
    @test rebuilt_tunables.constant == 3.0
    @test replaced_tunables.tunables == rebuilt_tunables.tunables
    @test replaced_tunables.constant == rebuilt_tunables.constant

    constants, repack_constants, aliases = canonicalize(Constants(), p)
    @test constants == [3.0]
    @test !aliases
    rebuilt_constants = repack_constants([6.0])
    replaced_constants = replace(Constants(), p, [6.0])
    @test rebuilt_constants.tunables == [1.0, 2.0]
    @test rebuilt_constants.constant == 6.0
    @test replaced_constants.tunables == rebuilt_constants.tunables
    @test replaced_constants.constant == rebuilt_constants.constant
    @test replace!(Tunable(), p, [7.0, 8.0]) === nothing
    @test p.tunables == [7.0, 8.0]
    @test replace!(Constants(), p, [9.0]) === nothing
    @test p.constant == 9.0
end
