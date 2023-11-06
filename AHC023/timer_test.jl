function f()
    a = [[1, 2, 3], [3, 4, 5], [5, 6, 7]]
    @show a

    b = a[2]
    b[3] = 6
    @show b
    @show a

    c = deepcopy(a[3])
    c[3] = 8
    @show c
    @show a

    d = Dict{Int,Bool}()
    d[1] = true
    @show all(values(d))
    return
end

f()