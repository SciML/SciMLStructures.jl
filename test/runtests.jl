using SciMLStructures, Test, SafeTestsets

const GROUP = get(ENV, "GROUP", "all")

@testset "SciMLStructures" begin
    if GROUP == "all" || GROUP == "core"
        @safetestset "Quality Assurance" include("qa.jl")
    end

    if GROUP == "all" || GROUP == "nopre"
        @safetestset "Allocation Tests" include("alloc_tests.jl")
    end
end
