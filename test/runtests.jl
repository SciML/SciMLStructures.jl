using Pkg
using SafeTestsets, Test

const GROUP = get(ENV, "GROUP", "All")

@testset "SciMLStructures" begin
    if GROUP == "All" || GROUP == "Core"
        Pkg.activate("alloccheck")
        Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
        Pkg.instantiate()
        @safetestset "Allocation Tests" include("alloccheck/alloc_tests.jl")
    end

    if GROUP == "All" || GROUP == "QA"
        Pkg.activate("qa")
        Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
        Pkg.instantiate()
        @safetestset "Quality Assurance" include("qa/qa.jl")
    end
end
