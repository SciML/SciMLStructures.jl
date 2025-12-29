using SciMLStructures
using SciMLStructures: Tunable, Constants, Caches, Discrete, Initials, Input,
    canonicalize, hasportion, isscimlstructure
using AllocCheck
using Test

@testset "AllocCheck - Zero Allocations" begin
    @testset "hasportion checks" begin
        arr = rand(10)

        @check_allocs check_hasportion_tunable(a) = hasportion(Tunable(), a)
        @check_allocs check_hasportion_constants(a) = hasportion(Constants(), a)
        @check_allocs check_hasportion_caches(a) = hasportion(Caches(), a)
        @check_allocs check_hasportion_discrete(a) = hasportion(Discrete(), a)
        @check_allocs check_hasportion_initials(a) = hasportion(Initials(), a)

        @test check_hasportion_tunable(arr) == true
        @test check_hasportion_constants(arr) == false
        @test check_hasportion_caches(arr) == false
        @test check_hasportion_discrete(arr) == false
        @test check_hasportion_initials(arr) == false
    end

    @testset "isscimlstructure checks" begin
        arr = rand(10)
        arr_int = [1, 2, 3]
        arr_any = Any[1, 2, 3]

        @check_allocs check_isscimlstructure(a::Vector{Float64}) = isscimlstructure(a)
        @check_allocs check_isscimlstructure_int(a::Vector{Int}) = isscimlstructure(a)

        @test check_isscimlstructure(arr) == true
        @test check_isscimlstructure_int(arr_int) == true
        @test isscimlstructure(arr_any) == false
    end

    @testset "canonicalize for Vector (aliased, zero alloc)" begin
        arr = rand(10)

        @check_allocs function check_canonicalize_vec(a::Vector{Float64})
            canonicalize(Tunable(), a)
        end

        vals, repack, aliases = check_canonicalize_vec(arr)
        @test vals === arr
        @test aliases == true
    end

    @testset "canonicalize returns for other portions" begin
        arr = rand(10)

        @check_allocs check_canon_constants(a::Vector{Float64}) = canonicalize(Constants(), a)
        @check_allocs check_canon_caches(a::Vector{Float64}) = canonicalize(Caches(), a)
        @check_allocs check_canon_discrete(a::Vector{Float64}) = canonicalize(Discrete(), a)

        @test check_canon_constants(arr) == (nothing, nothing, nothing)
        @test check_canon_caches(arr) == (nothing, nothing, nothing)
        @test check_canon_discrete(arr) == (nothing, nothing, nothing)
    end
end
