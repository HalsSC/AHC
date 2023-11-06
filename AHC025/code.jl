using Distributions
start_time = time()
const wait_time = 1.81
mutable struct queryBuilder
    memo::Dict{String,Int}
    cnt::Int
    n::Int
    d::Int
    q::Int
end

function queryBuilder(n, d, q)
    return queryBuilder(Dict{String,Int}(), 0, n, d, q)
end

function is_query_limit(qb::queryBuilder)
    return qb.cnt >= qb.q
end

function query_leftover(qb::queryBuilder, w)
    for _ = qb.cnt+1:qb.q
        println("1 1 0 1")
        flush(stdout)
        _ = input()
        qb.cnt += 1
    end
end

function query(qb::queryBuilder, nl::Int, nr::Int, l::Vector{Int}, r::Vector{Int}, w)
    @assert nl > 0
    @assert nr > 0
    @assert nl == length(l)
    @assert nr == length(r)
    @assert isempty(intersect(Set(l), Set(r)))
    text = "$nl $nr $(join(l," ")) $(join(r," "))"
    haskey(qb.memo, text) && return qb.memo[text]
    # is_query_limit(qb) && return nothing
    println(text)
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
        res = lsum > rsum ? 1 : (lsum == rsum ? 0 : -1)
    end
    qb.cnt += 1
    qb.memo[text] = res
    qb.memo["$nr $nl $(join(r," ")) $(join(l," "))"] = -res # l,rが逆の場合も登録
    return res
end

function answer(d, comment=false)
    comment && print("#c ") # ビジュアライザ用のコメント
    println(join(d, " "))
end

function make_group(group_num, ans)
    n = length(ans)
    g = Vector{Int}()
    for i = 1:n
        if ans[i] == group_num
            push!(g, i - 1)
        end
    end
    g
end

function get_score(d, ans, w)
    if isnothing(w)
        score = 0
    else
        groups = zeros(Int, d)
        for (ans_i, w_i) = zip(ans, w)
            groups[ans_i+1] += w_i
        end
        ave = sum(groups) / d
        v = 0
        for i = 1:d
            v += (groups[i] - ave)^2
        end
        score = 1 + round(Int, 100 * sqrt(v / d))
    end
    score
end

function init_ans(n, d, q, qb, w=nothing)
    ans = [(i - 1) % d for i = 1:n]
    answer(ans, true)
    ans
end

function solve(n, d, q, skip, w=nothing)
    qb = queryBuilder(n, d, q)
    ans = init_ans(n, d, q, qb, w)
    answer(ans, true)
    best_ans = ans
    while !is_query_limit(qb)
        time() - start_time > wait_time && break
        minnum, maxnum = 0, 0
        mingroup = make_group(minnum, ans)
        maxgroup = make_group(maxnum, ans)
        for i = 1:d-1
            is_query_limit(qb) && break
            time() - start_time > wait_time && break
            g = make_group(i, ans)
            if query(qb, length(mingroup), length(g), mingroup, g, w) == 1
                minnum = i
                mingroup = deepcopy(g)
            end
            is_query_limit(qb) && break
            if query(qb, length(maxgroup), length(g), maxgroup, g, w) == -1
                maxnum = i
                maxgroup = deepcopy(g)
            end
            is_query_limit(qb) && break
        end
        is_query_limit(qb) && break
        time() - start_time > wait_time && break
        length(maxgroup) < 2 && continue
        min_in_max = maxgroup[1]
        for val = maxgroup
            is_query_limit(qb) && break
            val == min_in_max && continue
            ret = query(qb, 1, 1, [min_in_max], [val], w)
            if ret == 1
                min_in_max = val
            end
        end
        if rand() < skip^(qb.cnt / q)
            println("# $min_in_max : $(ans[min_in_max+1]) -> $minnum")
            ans[min_in_max+1] = minnum
            best_ans = deepcopy(ans)
            answer(ans, true)
        else
            println("# skipped!")
        end
        time() - start_time > wait_time && break
        is_query_limit(qb) && break
    end
    query_leftover(qb, w)   # クエリ数がQに満たない場合に使い切る
    answer(best_ans, false)
    best_ans
end

function main()
    n, d, q = int(inputs())
    solve(n, d, q, 0.27)
end

function _main()
    global start_time = time()
    n, d, q = int(inputs())
    debug("n=$n d=$d q=$q (q=$(trunc(Int,q/n*100)/100)n)")
    w = int(inputs())
    score = get_score(d, solve(n, d, q, 0.27, w), w)
    return score
end

input() = readline()
inputs() = split(readline())
int(s::AbstractChar)::Int = parse(Int, s)
int(s::AbstractString)::Int = parse(Int, s)
int(v::AbstractArray)::Vector{Int} = map(x -> parse(Int, x), v)
debug(x...) = println(stderr, x...)
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end