using Pkg
using SciMLStructures, Test, SafeTestsets

const GROUP = get(ENV, "GROUP", "all")

function activate_alloccheck_env()
    Pkg.activate("alloccheck")
    Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
    Pkg.instantiate()
end

@testset "SciMLStructures" begin
    if GROUP == "all" || GROUP == "core"
        @safetestset "Quality Assurance" include("qa.jl")
    end

    if GROUP == "all" || GROUP == "nopre"
        activate_alloccheck_env()
        @safetestset "Allocation Tests" include("alloccheck/alloc_tests.jl")
    end
end
