using SciMLTesting

run_tests(;
    core = (; env = joinpath(@__DIR__, "Core"), body = joinpath(@__DIR__, "Core", "alloc_tests.jl")),
    qa = (; env = joinpath(@__DIR__, "qa"), body = joinpath(@__DIR__, "qa", "qa.jl")),
    all = ["Core", "QA"],
)
