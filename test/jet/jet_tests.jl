using SciMLStructures, JET, Test
using SciMLStructures: Tunable, Constants, Caches, Discrete, Initials, Input,
    canonicalize, hasportion, isscimlstructure, replace

@testset "JET static analysis" begin
    x = [1.0, 2.0, 3.0]
    mat = [1.0 2.0; 3.0 4.0]

    @testset "hasportion type stability" begin
        @test_opt target_modules = (SciMLStructures,) hasportion(Tunable(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Constants(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Caches(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Discrete(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Initials(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Input(), x)
    end

    @testset "isscimlstructure type stability" begin
        @test_opt target_modules = (SciMLStructures,) isscimlstructure(x)
        @test_opt target_modules = (SciMLStructures,) isscimlstructure(mat)
    end

    @testset "canonicalize type stability" begin
        @test_opt target_modules = (SciMLStructures,) canonicalize(Tunable(), x)
        @test_opt target_modules = (SciMLStructures,) canonicalize(Constants(), x)
        @test_opt target_modules = (SciMLStructures,) canonicalize(Caches(), x)
        @test_opt target_modules = (SciMLStructures,) canonicalize(Discrete(), x)
        @test_opt target_modules = (SciMLStructures,) canonicalize(Initials(), x)
        @test_opt target_modules = (SciMLStructures,) canonicalize(Input(), x)
        @test_opt target_modules = (SciMLStructures,) canonicalize(Tunable(), mat)
    end

    @testset "replace type stability" begin
        @test_opt target_modules = (SciMLStructures,) replace(Tunable(), x, [4.0, 5.0, 6.0])
        @test_opt target_modules = (SciMLStructures,) replace(
            Tunable(), mat, [5.0, 6.0, 7.0, 8.0]
        )
    end
end
