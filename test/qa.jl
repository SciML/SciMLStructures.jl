using SciMLStructures, Aqua, JET
using SciMLStructures: Tunable, Constants, Caches, Discrete, Initials,
    canonicalize, hasportion, isscimlstructure, replace

@testset "Aqua" begin
    Aqua.find_persistent_tasks_deps(SciMLStructures)
    Aqua.test_ambiguities(SciMLStructures, recursive = false)
    Aqua.test_deps_compat(SciMLStructures)
    Aqua.test_piracies(SciMLStructures)
    Aqua.test_project_extras(SciMLStructures)
    Aqua.test_stale_deps(SciMLStructures)
    Aqua.test_unbound_args(SciMLStructures)
    Aqua.test_undefined_exports(SciMLStructures)
end

@testset "JET static analysis" begin
    x = [1.0, 2.0, 3.0]
    mat = [1.0 2.0; 3.0 4.0]

    @testset "hasportion type stability" begin
        @test_opt target_modules = (SciMLStructures,) hasportion(Tunable(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Constants(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Caches(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Discrete(), x)
        @test_opt target_modules = (SciMLStructures,) hasportion(Initials(), x)
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
        @test_opt target_modules = (SciMLStructures,) canonicalize(Tunable(), mat)
    end

    @testset "replace type stability" begin
        @test_opt target_modules = (SciMLStructures,) replace(Tunable(), x, [4.0, 5.0, 6.0])
        @test_opt target_modules = (SciMLStructures,) replace(
            Tunable(), mat, [5.0, 6.0, 7.0, 8.0])
    end
end
