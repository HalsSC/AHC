using Revise
include("code.jl")

debug(x...) = println(stderr, x...)
function test()
    score_sum = 0
    seed = 0
    @time for seed = 0:99
        filename = lpad(seed, 4, "0")
        mystdin = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        mystdout = joinpath(abspath(@__DIR__), "out\\$filename.txt")
        redirect_stdio(stdin=mystdin, stdout=mystdout) do
            score_sum += _main()
        end
        debug(score_sum)
    end
    debug("average(seed=0):", score_sum)
end

test()
