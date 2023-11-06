function f()
    start = 0
    last = 20
    for seed = start:last-1
        filename = lpad(seed, 4, "0")
        mystdin = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        new_answers = []
        redirect_stdio(stdin=mystdin) do
            while true
                for i = 1:50
                    ans_i = int(inputs())
                end
            end
        end
    end
end

input() = readline()
inputs() = split(readline())
int(s::AbstractChar)::Int = parse(Int, s)
int(s::AbstractString)::Int = parse(Int, s)
int(v::AbstractArray)::Vector{Int} = map(x -> parse(Int, x), v)
debug(x...) = println(stderr, x...)
f()