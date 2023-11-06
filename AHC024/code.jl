const n = 50
const m = 100
const dir4 = ((-1, 0), (1, 0), (0, -1), (0, 1))
const dir8 = ((-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 0), (0, 1), (1, -1), (1, 0), (1, 1))
const for_dir = ((1:n, 1:n,), (n:-1:1, 1:n), (1:n, n:-1:1,), (n:-1:1, n:-1:1,))
start_time = time()
const wait_time = 1.83
f(i, j) = (i - 1) * n + j
rf(ij) = (ij - 1) ÷ n + 1, (ij - 1) % n + 1
using DataStructures: IntDisjointSets, union!, in_same_set
macro chmin!(a, b)
    esc(:($a > $b ? ($a = $b; true) : false))
end
macro chmax!(a, b)
    esc(:($a < $b ? ($a = $b; true) : false))
end

function answer(ans)
    println.([join(ans[i, :], " ") for i = 1:n])
end

function get_score(ans)
    res = 0
    for i = 1:n, j = 1:n
        if ans[i, j] == 0
            res += 1
        end
    end
    res + 1
end

function isok(ans, y, x, default_rinsetsu)
    uf = IntDisjointSets(n^2)
    rinsetsu = falses(m, m + 1)
    for i = 1:n, j = 1:n
        ans[i, j] == 0 && continue
        if i == y && j == x
            continue
        end
        for (di, dj) = dir4
            if i + di == y && j + dj == x
                rinsetsu[ans[i, j], 1] = true
            elseif 1 <= i + di <= n && 1 <= j + dj <= n
                if ans[i, j] == ans[i+di, j+dj]
                    union!(uf, f(i, j), f(i + di, j + dj))
                end
                rinsetsu[ans[i, j], ans[i+di, j+dj]+1] = true
            else
                rinsetsu[ans[i, j], 1] = true
            end
        end
    end
    daihyoten = zeros(Int, m)
    for i = 1:n, j = 1:n
        ans[i, j] == 0 && continue
        if i == y && j == x
            continue
        end
        ij = f(i, j)
        if daihyoten[ans[i, j]] == 0
            daihyoten[ans[i, j]] = ij
        else
            if !in_same_set(uf, ij, daihyoten[ans[i, j]])
                return false
            end
        end
    end
    for i = 1:m
        if default_rinsetsu[i, :] != rinsetsu[i, :]
            return false
        end
    end
    true
end

function is_zero_connect(new_ans)
    zero_conn = falses(n, n)
    q = []
    for i = 1:n, j = 1:n
        if new_ans[i, j] > 0
            continue
        end
        for (di, dj) = dir4
            if !(1 <= i + di <= n) || !(1 <= j + dj <= n)
                zero_conn[i, j] = true
                push!(q, f(i, j))
            end
        end
    end
    while !isempty(q)
        ij = popfirst!(q)
        i, j = rf(ij)
        for (di, dj) = dir4
            if 1 <= i + di <= n && 1 <= j + dj <= n && new_ans[i+di, j+dj] == 0 && !zero_conn[i+di, j+dj]
                zero_conn[i+di, j+dj] = true
                push!(q, f(i + di, j + dj))
            end
        end
    end
    for i = 1:n, j = 1:n
        if new_ans[i, j] == 0 && !zero_conn[i, j]
            return false
        end
    end
    return true
end

function remove(ans, new_ans, default_rinsetsu)
    is_zero_connect(new_ans) || return (false, ans)
    uf = IntDisjointSets(n^2)
    rinsetsu = falses(m, m + 1)
    ok = true
    for i = 1:n, j = 1:n
        new_ans[i, j] == 0 && continue
        for (di, dj) = dir4
            if 1 <= i + di <= n && 1 <= j + dj <= n
                if new_ans[i, j] == new_ans[i+di, j+dj]
                    union!(uf, f(i, j), f(i + di, j + dj))
                end
                rinsetsu[new_ans[i, j], new_ans[i+di, j+dj]+1] = true
            else
                rinsetsu[new_ans[i, j], 1] = true
            end
        end
    end
    daihyoten = zeros(Int, m)
    for i = 1:n, j = 1:n
        new_ans[i, j] == 0 && continue
        ij = f(i, j)
        if daihyoten[new_ans[i, j]] == 0
            daihyoten[new_ans[i, j]] = ij
        else
            if !in_same_set(uf, ij, daihyoten[new_ans[i, j]])
                ok = false
                break
            end
        end
    end
    for i = 1:m
        if daihyoten[i] == 0
            ok = false
            break
        end
        if default_rinsetsu[i, :] != rinsetsu[i, :]
            ok = false
            break
        end
    end
    return (ok, (ok ? new_ans : ans))
end

function remove_all(ans, default_rinsetsu)
    new_ans = deepcopy(ans)
    for row = 1:n
        ok, new_ans = row_remove(new_ans, row, 1, n, default_rinsetsu)
        if ok
            answer(new_ans)
        end
    end
    for col = 1:n
        ok, new_ans = col_remove(new_ans, 1, n, col, default_rinsetsu)
        if ok
            answer(new_ans)
        end
    end
    return new_ans
end

function row_remove(ans, y, x1, x2, default_rinsetsu)
    new_ans = zeros(Int, n, n)
    for row = 1:n, col = 1:n
        new_row, new_col = row, col
        if y <= row && x1 <= col <= x2
            new_row += 1
        end
        if new_row > n
            new_ans[row, col] = 0
        else
            new_ans[row, col] = ans[new_row, new_col]
        end
    end
    remove(ans, new_ans, default_rinsetsu)
end

function col_remove(ans, y1, y2, x, default_rinsetsu)
    new_ans = zeros(Int, n, n)
    for row = 1:n, col = 1:n
        new_row, new_col = row, col
        if y1 <= row <= y2 && x <= col
            new_col += 1
        end
        if new_col > n
            new_ans[row, col] = 0
        else
            new_ans[row, col] = ans[new_row, new_col]
        end
    end
    remove(ans, new_ans, default_rinsetsu)
end

function random_row_remove(ans, default_rinsetsu)
    row = rand(1:n-1)
    col_s = rand(1:n)
    len = rand(0:n)
    col_e = min(n, col_s + len)
    ok, new_ans = row_remove(ans, row, col_s, col_e, default_rinsetsu)
    if ok
        answer(ans)
        return new_ans
    else
        return ans
    end
end

function random_col_remove(ans, default_rinsetsu)
    col = rand(1:n-1)
    row_s = rand(1:n)
    len = rand(0:n)
    row_e = min(n, row_s + len)
    ok, new_ans = col_remove(ans, row_s, row_e, col, default_rinsetsu)
    if ok
        answer(new_ans)
        return new_ans
    else
        return ans
    end
end

function reduce_outer(ans, default_rinsetsu)
    new_ans = deepcopy(ans)
    for (range_i, range_j) = for_dir
        if time() - start_time > wait_time
            return new_ans
        end
        for i = range_i, j = range_j
            if time() - start_time > wait_time
                return new_ans
            end
            if new_ans[i, j] == 0
                continue
            end
            zflg = false
            corner_flg = false
            for (di, dj) = dir4
                if 1 <= i + di <= n && 1 <= j + dj <= n
                    if new_ans[i+di, j+dj] == 0
                        zflg = true
                        break
                    end
                else
                    corner_flg = true
                end
            end
            if (corner_flg || zflg) && isok(new_ans, i, j, default_rinsetsu)
                new_ans[i, j] = 0
                # answer(ans)
            end
        end
    end
    if ans != new_ans
        answer(new_ans)
    end
    return new_ans
end

function solve(c)
    default_rinsetsu = falses(m, m + 1)
    ans = zeros(Int, n, n)
    for i = 1:n, j = 1:n
        ans[i, j] = c[i][j]
        for (di, dj) = dir4
            if 1 <= i + di <= n && 1 <= j + dj <= n
                default_rinsetsu[c[i][j], c[i+di][j+dj]+1] = true
            else
                default_rinsetsu[c[i][j], 1] = true
            end
        end
    end
    answer(ans)
    if time() - start_time > wait_time
        answer(ans)
        return get_score(ans)
    end
    ans = remove_all(ans, default_rinsetsu)
    for loop = 1:1000000
        if time() - start_time > wait_time
            break
        end
        if loop % 100 == 1
            ans = reduce_outer(ans, default_rinsetsu)
            # answer(ans)
        end
        ans = random_row_remove(ans, default_rinsetsu)
        if time() - start_time > wait_time
            break
        end
        ans = random_col_remove(ans, default_rinsetsu)
    end
    answer(ans)
    get_score(ans)
end

function main()
    readline()
    c = [int(inputs()) for _ = 1:n]
    solve(c)
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