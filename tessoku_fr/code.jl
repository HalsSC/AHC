using DataStructures
using Random

# ----------solution----------
function getscore(cnt_p, cnt_q)
    score = min(minimum(cnt_p) / maximum(cnt_p), minimum(cnt_q) / maximum(cnt_q))
    return score
end

function main()
    n, k, l = int(inputs())
    ab = [int(inputs()) for _ = 1:k]
    c = [int(inputs()) for _ = 1:n]
    rinsetsu = Vector{Vector{Int}}([Vector{Int}() for _ = 1:k])
    for i = 1:n, j = 1:n
        c[i][j] == 0 && continue
        for (ni, nj) = [(i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1)]
            if 1 <= ni <= n && 1 <= nj <= n && c[ni][nj] != 0 && c[i][j] != c[ni][nj]
                push!(rinsetsu[c[i][j]], c[ni][nj])
            end
        end
    end
    for i = 1:k
        rinsetsu[i] = unique(rinsetsu[i])
    end
    ans = zeros(Int, k)
    bestscore = -1
    function f(ans, starts)
        res = zeros(Int, k)
        cnt_p = zeros(Int, l)
        cnt_q = zeros(Int, l)
        gone = falses(k)
        pq = PriorityQueue{Int,Int}()
        nexts = [Set{Int}() for _ = 1:l]
        for i = 1:l
            start = (starts[i] - 1) % k + 1
            res[start] = i
            gone[start] = true
            cnt_p[i] += ab[start][1]
            cnt_q[i] += ab[start][2]
            pq[i] = cnt_p[i]
            for j = rinsetsu[start]
                !gone[j] && push!(nexts[i], j)
            end
        end
        times = l
        while times < k
            group, _ = peek(pq)
            if isempty(nexts[group])
                dequeue!(pq)
            end
            while !isempty(nexts[group])
                next = pop!(nexts[group])
                gone[next] && continue
                a, b = ab[next]
                times += 1
                res[next] = group
                gone[next] = true
                cnt_p[group] += a
                cnt_q[group] += b
                pq[group] += a
                for j = rinsetsu[next]
                    !gone[j] && push!(nexts[group], j)
                end
                break
            end
        end
        nowscore = getscore(cnt_p, cnt_q)
        if nowscore > bestscore
            bestscore = nowscore
            return res
        else
            return ans
        end
    end
    ans = f(ans, 1:l)
    rands = rand(1:k, 120)
    for start = rands
        ans = f(ans, start:start+l-1)
    end
    println.(ans)
    return
end
# ----------------------------

# --------input func----------
input() = readline()
inputs() = split(readline())
int(s::AbstractChar) = parse(Int, s)
int(s::AbstractString) = parse(Int, s)
int(v::AbstractArray) = map(x -> parse(Int, x), v)

if abspath(PROGRAM_FILE) == @__FILE__
    main()
else
    mystdin = joinpath(abspath(@__DIR__), "sample-in\\in000.txt")
    mystdout = joinpath(abspath(@__DIR__), "sample-out\\out000.txt")
    redirect_stdio(stdin=mystdin, stdout=mystdout) do
        main()
    end
end