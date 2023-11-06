function f()
    for seed = 0:99
        filename = lpad(seed, 4, "0")
        intxt = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        outtxt = joinpath(abspath(@__DIR__), "out\\$filename.txt")
        # @show filename
        run(`./vis.exe $intxt $outtxt`)
    end
end
# f()

mutable struct queryBuilder
    memo::Dict{Tuple{Vector{Int},Vector{Int}},Int}
    cnt::Int
    n::Int
    d::Int
    q::Int
end

function queryBuilder(n, d, q)
    return queryBuilder(Dict{Tuple{Vector{Int},Vector{Int}},Int}(), 0, n, d, q)
end

function query(qf::queryBuilder, nl, nr, l, r, w)
    haskey(qf.memo, (l, r)) && return qf.memo[l, r]
    qf.cnt >= qf.q && return nothing
    println("$nl $nr $(join(l," ")) $(join(r," ")))")
    flush(stdout)
    if isnothing(w)
        inp = input()
        res = inp == ">" ? 1 : (inp == "=" ? 0 : -1)
    else
        lsum, rsum = 0, 0
        for i = l
            lsum += w[i+1]
        end
        for i = r
            rsum += w[i+1]
        end
        lsum > rsum && return 1
        lsum == rsum && return 0
        return -1
    end
    qf.cnt += 1
    qf.memo[(l, r)] = res
    return res
end


function main()
    n = 31
    d = 3
    q = 128
    # qf = queryBuilder(n, d, q)
    # debug(qf.memo)
    # query(qf, 1, 1, [1], [1], nothing)
    # debug(qf.memo)
    # debug(qf.cnt)
    # query(qf, 1, 1, [1], [1], nothing)
    # debug(qf.memo)
    # debug(qf.cnt)
    for i = 1:n
        if (i - 1) ÷ d % 2 == 0
            debug((i - 1) % d)
        else
            debug(d - (i - 1) % d - 1)
        end
    end
end

input() = readline()
inputs() = split(readline())
int(s::AbstractChar)::Int = parse(Int, s)
int(s::AbstractString)::Int = parse(Int, s)
int(v::AbstractArray)::Vector{Int} = map(x -> parse(Int, x), v)
debug(x...) = println(stderr, x...)
main()