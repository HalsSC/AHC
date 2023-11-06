# seed=0でScore=209675
const t = 100
const h = 20
const w = 20
const dir = ((-1, 0), (1, 0), (0, -1), (0, 1))
const start_time = time()
const wait_time = 10
f(i, j) = (i - 1) * w + j
rf(ij) = (ij - 1) ÷ w + 1, (ij - 1) % w + 1
macro chmin!(a, b)
    esc(:($a > $b ? ($a = $b; true) : false))
end
macro chmax!(a, b)
    esc(:($a < $b ? ($a = $b; true) : false))
end

function answer(ans::Vector{NTuple{5,Int}})
    println(length(ans))
    tmp = [join([k, i - 1, j - 1, s], " ") for (k, i, j, s) = ans]
    println.(tmp)
end

function isused(ij::Int, plant::Int, heavest::Int, used::Vector{Vector{UnitRange{Int}}})
    for range = used[ij]
        start, stop = range.start, range.stop
        if heavest == 0     # 植えるときに占有がいないか
            if start <= plant <= stop
                return true
            end
        elseif plant == 0   # 収穫するときに占有がいないか
            if start <= heavest <= stop
                return true
            end
        elseif start <= plant <= stop || start <= heavest <= stop || plant <= start <= heavest || plant <= stop <= heavest   # 別の植えてる期間に被らないか
            return true
        end
    end
    false
end

function cango(MAP::BitMatrix, i::Int, j::Int, di::Int, dj::Int)
    1 <= i + di <= h || return false
    1 <= j + dj <= w || return false
    return MAP[2i+di, 2j+dj]
end

function make_indexes(MAP::BitMatrix, i0::Int)::Vector{NTuple{3,Int}}
    dis = fill(1 << 10, h * w)
    s = f(i0, 1)
    dis[s] = 0
    q = [s]
    while !isempty(q)
        ij = popfirst!(q)
        i, j = rf(ij)
        for (di, dj) = dir
            nij = f(i + di, j + dj)
            if cango(MAP, i, j, di, dj) && @chmin!(dis[nij], dis[ij] + 1)
                push!(q, nij)
            end
        end
    end
    pq::Vector{NTuple{3,Int}} = []
    for i = 1:h, j = 1:w
        push!(pq, (i, j, dis[f(i, j)]))
    end
    sort!(pq, by=x -> x[3], rev=true)
    pq = pq[1:end-1]
    pq
end

function make_map()::BitMatrix
    MAP = falses(2 * h, 2 * w)
    for i = 1:h-1
        hh = int(collect(input()))
        for j = 1:w
            MAP[2i+1, 2j] = iszero(hh[j])
        end
    end
    for i = 1:h
        vv = int(collect(input()))
        for j = 1:w-1
            MAP[2i, 2j+1] = iszero(vv[j])
        end
    end
    MAP
end

function distance2(MAP::BitMatrix, s::Int, g::Int, plant::Int, heavest::Int, used::Vector{Vector{UnitRange{Int}}})
    dis = fill(1 << 10, h * w)
    dis[s] = 0
    q = [s]
    while !isempty(q)
        ij = popfirst!(q)
        i, j = rf(ij)
        for (di, dj) = dir
            nij = f(i + di, j + dj)
            if nij == g && cango(MAP, i, j, di, dj)
                dis[nij] = dis[ij] + 1
                return dis[nij]
            end
            if cango(MAP, i, j, di, dj) && !isused(nij, plant, heavest, used) && @chmin!(dis[nij], dis[ij] + 1)
                push!(q, nij)
            end
        end
    end
    1 << 10
end

function isok(i0::Int, MAP::BitMatrix, ans::Vector{NTuple{5,Int}}, ij::Int, plant::Int, heavest::Int, used::Vector{Vector{UnitRange{Int}}})
    isused(ij, plant, heavest, used) && return 0
    time() - start_time >= wait_time && return 0
    score = 0
    used_ = deepcopy(used)
    push!(used_[ij], plant:heavest+1)  # 収穫の月に設置はできない
    i_, j_ = rf(ij)
    ans_ = vcat(ans, [(1, i_, j_, plant, heavest)])
    for (k, i, j, s, d) = ans_
        if distance2(MAP, f(i0, 1), f(i, j), s, d, used_) > h * w
            return 0
        end
        time() - start_time >= wait_time && return 0
        score += d - s + 1
    end
    # debug(10^6 * score ÷ (t * h * w))
    return 10^6 * score ÷ (t * h * w)
end

function solve(i0::Int, MAP::BitMatrix, k::Int, sd::Vector{Vector{Int}})::Int
    start = f(i0, 1)
    ans = Vector{NTuple{5,Int}}()
    done = falses(k)
    indexes = make_indexes(MAP, i0)
    sdi::Vector{NTuple{3,Int}} = [(sd[i][1], sd[i][2], i) for i = 1:k]
    sort!(sdi, by=x -> x[1], rev=true)
    sort!(sdi, by=x -> x[2] - x[1], rev=true)
    used::Vector{Vector{UnitRange{Int}}} = []   # used[ij,h] := {時刻hで(i,j)が使用されている/いない}
    for _ = 1:h*w
        push!(used, Vector{UnitRange{Int}}())
    end
    best_score = 0
    best_ans = Vector{NTuple{5,Int}}()
    for (s, d, i) = sdi
        isempty(indexes) && break
        (y, x, _) = popfirst!(indexes)
        yx = f(y, x)
        isused(yx, s, d, used) && continue
        score = isok(i0, MAP, ans, yx, s, d, used)
        if @chmax!(best_score, score)
            done[i] = true
            push!(used[yx], s:d+1)  # 収穫の月に設置はできない
            push!(ans, (i, y, x, s, d))
            best_ans = deepcopy(ans)
        end
        if time() - start_time >= wait_time
            break
        end
    end
    sort!(sdi, by=x -> x[2] - x[1], rev=true)
    for (s, d, i) = sdi
        done[i] && continue
        (y, x) = rand(1:h), rand(1:w)
        (y, x) == (i0, 1) && continue
        yx = f(y, x)
        isused(yx, s, d, used) && continue
        if time() - start_time >= wait_time
            break
        end
        score = isok(i0, MAP, ans, yx, s, d, used)
        if @chmax!(best_score, score)
            done[i] = true
            push!(used[yx], s:d+1)  # 収穫の月に設置はできない
            push!(ans, (i, y, x, s, d))
            best_ans = deepcopy(ans)
        end
        if time() - start_time >= wait_time
            break
        end
    end
    answer(best_ans)
    best_score
end

function main()
    # start_time = time()
    # wait_time = 5
    _, _, _, i0 = int(inputs())
    i0 += 1 # 出入口は(i, j) = (i0, 1)
    # hh = [int(collect(input())) for _ = 1:h-1] # hh[i][j] := (i,j)の下側に水路があるか
    # vv = [int(collect(input())) for _ = 1:h] # vv[i][j] := (i,j)の右側に水路があるか
    MAP = make_map()
    k = int(input())
    sd = [int(inputs()) for _ = 1:k]
    solve(i0, MAP, k, sd)
end

debug(x...) = println(stderr, x...)
function test()
    score_sum = 0
    for file = 0:99
        filename = lpad(file, 4, "0")
        mystdin = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        mystdout = joinpath(abspath(@__DIR__), "out\\$filename.txt")
        redirect_stdio(stdin=mystdin, stdout=mystdout) do
            score_sum += main()
        end
    end
    debug("score_sum:", Int(score_sum))
end


input() = readline()
inputs() = split(readline())
int(s::AbstractChar)::Int = parse(Int, s)
int(s::AbstractString)::Int = parse(Int, s)
int(v::AbstractArray)::Vector{Int} = map(x -> parse(Int, x), v)
if abspath(PROGRAM_FILE) == @__FILE__
    main()
else
    test()
end