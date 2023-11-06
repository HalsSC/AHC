using Revise
include("code.jl")

debug(x...) = println(stderr, x...)
function test()
    score_sum = 0
    start = 0
    last = 5
    @time for seed = start:last-1
        print(stderr, "seed=$seed ")
        filename = lpad(seed, 4, "0")
        mystdin = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        mystdout = joinpath(abspath(@__DIR__), "out\\$filename.txt")
        redirect_stdio(stdin=mystdin, stdout=mystdout) do
            score = main()
            score_sum += score
            # debug(filename, ": ", score)
        end
        run(`./vis.exe in\\$filename.txt out\\$filename.txt`)
    end
    debug("score_sum($(last-start)):", score_sum)
end

test()
