const t = 100   # 時間
const h = 20
const w = 20
const hw = 400
const thw = 40000
const dir = ((-1, 0), (1, 0), (0, -1), (0, 1))
start_time = time()
const wait_time = 1.83
using DataStructures: PriorityQueue, dequeue!
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
    println.([join([k, i - 1, j - 1, s], " ") for (k, i, j, s) = ans])
end

function isused(ij::Int, plant::Int, heavest::Int, used::Vector{Vector{UnitRange{Int}}})
    for range = used[ij]
        start, stop = range.start, range.stop
        if stop < plant
            continue
        end
        if heavest < start
            continue
        end
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

function cango(MAP::BitMatrix, ij::Int, di::Int, dj::Int)
    i, j = rf(ij)
    1 <= i + di <= h || return false
    1 <= j + dj <= w || return false
    return MAP[2i+di, 2j+dj]
end

@inbounds function make_map()::BitMatrix
    # hh = [int(collect(input())) for _ = 1:h-1] # hh[i][j] := (i,j)の下側に水路があるか
    # vv = [int(collect(input())) for _ = 1:h] # vv[i][j] := (i,j)の右側に水路があるか
    MAP = falses(2 * h, 2 * w)
    for i = 1:h-1
        hh = int(collect(input()))
        @simd for j = 1:w
            MAP[2i+1, 2j] = iszero(hh[j])
        end
    end
    for i = 1:h
        vv = int(collect(input()))
        @simd for j = 1:w-1
            MAP[2i, 2j+1] = iszero(vv[j])
        end
    end
    MAP
end

function make_indexes(MAP::BitMatrix, i0::Int)
    dis = fill(1 << 10, hw)
    s = f(i0, 1)
    dis[s] = 0
    q = [s]
    while !isempty(q)
        ij = popfirst!(q)
        i, j = rf(ij)
        for (di, dj) = dir
            nij = f(i + di, j + dj)
            if cango(MAP, ij, di, dj) && @chmin!(dis[nij], dis[ij] + 1)
                push!(q, nij)
            end
        end
    end
    maxq = PriorityQueue{Int,Int}()
    @simd for ij = 1:hw
        maxq[ij] = -dis[ij]
    end
    maxq
end

function distance2(MAP::BitMatrix, s::Int, g::Int, plant::Int, heavest::Int, used::Vector{Vector{UnitRange{Int}}})
    dis = fill(1 << 10, hw)
    dis[s] = 0
    q = [s]
    while !isempty(q)
        ij = popfirst!(q)
        i, j = rf(ij)
        for (di, dj) = dir
            nij = f(i + di, j + dj)
            if nij == g && cango(MAP, ij, di, dj)
                dis[nij] = dis[ij] + 1
                return dis[nij]
            end
            if cango(MAP, ij, di, dj) && !isused(nij, plant, heavest, used) && @chmin!(dis[nij], dis[ij] + 1)
                push!(q, nij)
            end
        end
    end
    1 << 10
end

function isok(i0::Int, MAP::BitMatrix, ans::Vector{NTuple{5,Int}}, ij::Int, plant::Int, heavest::Int, used::Vector{Vector{UnitRange{Int}}})
    ij == f(i0, 1) && return 0
    isused(ij, plant, heavest, used) && return 0
    time() - start_time >= wait_time && return 0
    start = f(i0, 1)
    if distance2(MAP, start, ij, plant, heavest, used) > hw
        return 0
    end
    used_ = deepcopy(used)
    time() - start_time >= wait_time && return 0
    score = heavest - plant + 1
    push!(used_[ij], plant:heavest)  # 収穫の月に設置はできない
    for (_, i, j, s, d) = ans
        if distance2(MAP, start, f(i, j), s, d, used_) > hw
            return 0
        end
        time() - start_time >= wait_time && return 0
        score += d - s + 1
    end
    # debug(10^6 * score ÷ (t * hw))
    10^6 * score ÷ thw
end

@inbounds function solve(i0::Int, MAP::BitMatrix, k::Int, sd::Vector{Vector{Int}}, times, num_times)
    ans = Vector{NTuple{5,Int}}()
    done = falses(k)
    place_maxq = make_indexes(MAP, i0)
    plant_maxq = PriorityQueue{Int,Int}()
    @simd for i = 1:k
        plant_maxq[i] = sd[i][1] - sd[i][2]
    end
    used::Vector{Vector{UnitRange{Int}}} = []   # used[ij,h] := {時刻hで(i,j)が使用されている/いない}
    for _ = 1:hw
        push!(used, Vector{UnitRange{Int}}())
    end
    for _ = 1:times
        plant_maxq[peek(plant_maxq)[1]] += 1
    end
    best_score = 0
    best_ans = Vector{NTuple{5,Int}}()
    while true
        isempty(place_maxq) && break
        isempty(plant_maxq) && break
        yx = peek(place_maxq)[1]
        y, x = rf(yx)
        i = peek(plant_maxq)[1]
        if time() - start_time >= times * wait_time / num_times
            break
        end
        done[i] && continue
        s, d = sd[i]
        place_maxq[yx] += rand(5:20)
        plant_maxq[i] += rand(1:3)
        if !isused(yx, s, d, used)
            score = isok(i0, MAP, ans, yx, s, d, used)
            if @chmax!(best_score, score)
                done[i] = true
                push!(used[yx], s:d)  # 収穫の月に設置はできない
                push!(ans, (i, y, x, s, d))
                plant_maxq[i] = t + 1
                best_ans = deepcopy(ans)
            end
        end
        if time() - start_time >= times * wait_time / num_times
            break
        end
    end
    # answer(best_ans)
    best_score, best_ans
end

function main()
    _, _, _, i0 = int(inputs())
    i0 += 1 # 出入口は(i, j) = (i0, 1)
    MAP = make_map()
    k = int(input())    # 植える植物数(=タスク数)
    sd = [int(inputs()) for _ = 1:k]
    best_score = 0
    best_ans = Vector{NTuple{5,Int}}()
    limit = 2
    @simd for i = 1:limit
        score, ans = solve(i0, MAP, k, sd, i, limit)
        if @chmax!(best_score, score)
            best_ans = deepcopy(ans)
        end
    end
    answer(best_ans)
    best_score
end

function _main()
    global start_time = time()
    main()
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