islocal = false
start_time = time()
const wait_time = 3.8
using DataStructures

function set_temp(temp_list::Vector{Vector{Int}})
    placement_cost::Int = 0
    l = length(temp_list)
    for (i, row) = enumerate(temp_list)
        println(join(row, " "))
        for j = 1:l
            placement_cost += (temp_list[i][j] - temp_list[mod(i, l)+1][j])^2
            placement_cost += (temp_list[i][j] - temp_list[i][mod(j, l)+1])^2
        end
    end
    flush(stdout)
    placement_cost
end
function get_temp(temp_list::Vector{Vector{Int}}, i::Int, j::Int)
    l = length(temp_list)
    temp_list[mod(i, l)+1][mod(j, l)+1]
end
function measure(i::Int, y::Int, x::Int)
    println("$i $y $x")
    flush(stdout)
    v = int(input())
    if v == -1
        println(stderr, "something went wrong. i=$i y=$y x=$x")
        exit(1)
    end
    v
end
function measure_local(i::Int, y::Int, x::Int, l::Int, temp_list::Vector{Vector{Int}}, yx::Vector{Vector{Int}}, ans::Vector{Int})
    println("$i $y $x")
    flush(stdout)
    v = int(input())
    y1, x1 = yx[ans[i+1]+1]
    max(0, min(1000, v + get_temp(temp_list, mod(y1 + y, l), mod(x1 + x, l))))
end
function answer(est::Vector{Int})
    println("-1 -1 -1")
    ans = zeros(Int, length(est))
    for (i, e) = enumerate(est)
        ans[i] = e
    end
    println.(ans)
    flush(stdout)
end

function normal_pdf(x, mean, std)
    exp(-0.5 * ((x - mean) / std)^2) / (std * √(2π))
end

function ave_temp(measured_data, measured_cnt, i_in::Int, y1::Int, x1::Int, v)
    ind = (2 + y1) * 5 + x1 + 3
    if measured_cnt[i_in][ind] == 0
        measured_data[i_in][ind] = v
    else
        measured_data[i_in][ind] += v
    end
    measured_cnt[i_in][ind] += 1
end

# ::Vector{Float64}ってすると何か怒られる
function judge(best_lh_list, lh_list, placement_cost::Int, measure_cost::Int)
    cnt = 0
    diff_sum = 0.0
    for (lh1, lh2) = zip(lh_list, best_lh_list)
        diff_sum += lh1 - lh2
        if lh1 >= lh2
            cnt += 1
        end
    end
    # debug("cnt:", cnt, " ", diff_sum)
    cnt
end

# ----------solution----------
function solve(l::Int, n::Int, s::Int, yx::Vector{Vector{Int}}, ans=nothing)
    temp_list::Vector{Vector{Int}} = [zeros(Int, l) for _ = 1:l]
    red_i, red_j = 0, 0
    temp_list[red_i+1][red_j+1] = 950
    placement_cost = set_temp(temp_list)
    measure_cost = 0
    measured_data = [zeros(Int, n) for _ = 1:n]
    measured_cnt = [zeros(Int, n) for _ = 1:n]
    query_cnt = 0
    likelihoods = []
    for i_in = 1:n
        query_cnt >= 10000 && break
        time() - start_time >= wait_time && break
        for i_out = 1:n
            query_cnt >= 10000 && break
            time() - start_time >= wait_time && break
            y1, x1 = red_i - yx[i_out][1], red_j - yx[i_out][2]
            if islocal
                measured_data[i_in][i_out] += measure_local(i_in - 1, y1, x1, l, temp_list, yx, ans)
            else
                measured_data[i_in][i_out] += measure(i_in - 1, y1, x1)
            end
            query_cnt += 1
            measure_cost += 100 * (10 + abs(y1) + abs(x1))
            measured_cnt[i_in][i_out] += 1
            push!(likelihoods, (i_in, i_out, measured_data[i_in][i_out] / measured_cnt[i_in][i_out]))
        end
        query_cnt >= 10000 && break
        time() - start_time >= wait_time && break
    end
    est = fill(-1, n)
    used = falses(n)
    sort!(likelihoods, by=x -> x[3], rev=true)
    for h = 1:n^2
        (i_in, i_out, val) = likelihoods[h]
        est[i_in] != -1 && continue
        used[i_out] && continue
        est[i_in] = i_out - 1
        used[i_out] = true
    end
    # answer(est)
    while query_cnt < 10000
        time() - start_time >= wait_time && break
        i_in, i_out = rand(1:n), rand(1:n)
        y1, x1 = yx[i_out][1] - red_i, yx[i_out][2] - red_j
        if islocal
            measured_data[i_in][i_out] += measure_local(i_in - 1, y1, x1, l, temp_list, yx, ans)
        else
            measured_data[i_in][i_out] += measure(i_in - 1, y1, x1)
        end
        query_cnt += 1
        measure_cost += 100 * (10 + abs(y1) + abs(x1))
        measured_cnt[i_in][i_out] += 1
        push!(likelihoods, (i_in, i_out, measured_data[i_in][i_out] / measured_cnt[i_in][i_out]))
        est = fill(-1, n)
        used = falses(n)
        for h = 1:n^2
            (in, out, _) = likelihoods[h]
            est[in] != -1 && continue
            used[out] && continue
            est[in] = out - 1
            used[out] = true
        end
    end
    answer(est)
    est, placement_cost, measure_cost
end
# ----------------------------

function main()
    l, n, s = int(inputs())
    yx = [int(inputs()) for _ = 1:n]
    est, placement_cost, measure_cost = solve(l, n, s, yx)
    # debug(placement_cost, measure_cost)
end

function get_score_local(est, ans, placement_cost, measure_cost)
    w = 0
    for (e, a) = zip(est, ans)
        if e != a
            w += 1
        end
    end
    10^14 * 0.8^w / (placement_cost + measure_cost + 10^5)
end

function _main()    # ローカルテスタ用
    l, n, s = int(inputs())
    yx = [int(inputs()) for _ = 1:n]
    ans = [int(input()) for _ = 1:n]
    @time est, placement_cost, measure_cost = solve(l, n, s, yx, ans)
    myscore = ceil(Int, get_score_local(est, ans, placement_cost, measure_cost))
    debug("score:$myscore placement_cost:$placement_cost measure_cost:$measure_cost")
    myscore
end

function test()
    score_sum = 0
    for file = 0:99
        filename = lpad(file, 4, "0")
        mystdin = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        mystdout = joinpath(abspath(@__DIR__), "out\\$filename.txt")
        redirect_stdio(stdin=mystdin, stdout=mystdout) do
            global start_time = time()
            score_sum += _main()
        end
    end
    debug("score_sum:", Int(score_sum))
end

input() = readline()
inputs() = split(readline())
int(s::AbstractChar) = parse(Int, s)
int(s::AbstractString) = parse(Int, s)
int(v::AbstractArray) = map(x -> parse(Int, x), v)
debug(x...) = println(stderr, x...)
if abspath(PROGRAM_FILE) == @__FILE__
    main()
else
    global islocal = true
    test()
end