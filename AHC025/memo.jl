# start_time = time()
# const wait_time = 1.83
macro chmin!(a, b)
    esc(:($a > $b ? ($a = $b; true) : false))
end
macro chmax!(a, b)
    esc(:($a < $b ? ($a = $b; true) : false))
end

function query(nl, nr, l, r)
    println("$nl $nr $(join(l," ")) $(join(r," "))")
    flush(stdout)
    inp = input()
    inp == ">" && return 1
    inp == "=" && return 0
    return -1
end

function query_local(nl, nr, l, r, w)
    println("$nl $nr $(join(l," ")) $(join(r," "))")
    flush(stdout)
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

function answer(d, comment=false)
    comment && print("#c ") # ビジュアライザ用のコメント
    println(join(d, " "))
end

function make_group(group_num, n, ans)
    g = []
    for i = 1:n
        if ans[i] == group_num
            push!(g, i - 1)
        end
    end
    g
end

function solve(n, d, q)
    ans = [(i - 1) % d for i = 1:n]
    answer(ans, true)
    cnt = 0
    while cnt < q
        minnum, maxnum = 0, 0
        mingroup = make_group(minnum, n, ans)
        maxgroup = make_group(maxnum, n, ans)
        for i = 1:d-1
            cnt < q || break
            g = make_group(i, n, ans)
            ret = query(length(mingroup), length(g), mingroup, g)
            cnt += 1
            if ret == 1
                minnum = i
                mingroup = deepcopy(g)
            end
            cnt < q || break
            ret = query(length(maxgroup), length(g), maxgroup, g)
            cnt += 1
            if ret == -1
                maxnum = i
                maxgroup = deepcopy(g)
            end
            cnt < q || break
        end
        cnt < q || break
        length(maxgroup) < 2 && continue
        min_in_max = maxgroup[1]
        for val = maxgroup
            val == min_in_max && continue
            cnt < q || break
            cnt += 1
            if query(1, 1, min_in_max, val) == 1
                min_in_max = val
            end
        end
        ans[min_in_max+1] = minnum
        answer(ans, true)
        cnt < q || break
    end
    answer(ans, false)
    ans
end

function solve_local(n, d, q, w)
    ans = [(i - 1) % d for i = 1:n]
    answer(ans, true)
    cnt = 0
    while cnt < q
        minnum, maxnum = 0, 0
        mingroup = make_group(minnum, n, ans)
        maxgroup = make_group(maxnum, n, ans)
        for i = 1:d-1
            cnt < q || break
            g = make_group(i, n, ans)
            ret = query_local(length(mingroup), length(g), mingroup, g, w)
            cnt += 1
            if ret == 1
                minnum = i
                mingroup = deepcopy(g)
            end
            cnt < q || break
            ret = query_local(length(maxgroup), length(g), maxgroup, g, w)
            cnt += 1
            if ret == -1
                maxnum = i
                maxgroup = deepcopy(g)
            end
            cnt < q || break
        end
        cnt < q || break
        length(maxgroup) < 2 && continue
        min_in_max = maxgroup[1]
        for val = maxgroup
            val == min_in_max && continue
            cnt < q || break
            cnt += 1
            if query_local(1, 1, min_in_max, val, w) == 1
                min_in_max = val
            end
        end
        ans[min_in_max+1] = minnum
        answer(ans, true)
        cnt < q || break
    end
    answer(ans, false)
    ans
end

function main()
    n, d, q = int(inputs())
    solve(n, d, q)
end

function _main()
    # global start_time = time()
    n, d, q = int(inputs())
    w = int(inputs())
    solve_local(n, d, q, w)
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