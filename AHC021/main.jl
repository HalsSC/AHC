# ----------solution----------
function solve(n, l, pyramid)
    ans = []
    for _ = 1:25
        for num = 0:l-1
            flag = false
            for i = 1:n, j = 1:i
                if pyramid[i][j] != num
                    continue
                end
                y, x = i, j
                while true
                    ind = -1
                    if y == 1
                        break
                    end
                    if 1 < x && x <= y - 1
                        if pyramid[y-1][x] < pyramid[y-1][x-1] && pyramid[y][x] < pyramid[y-1][x-1]
                            ind = x - 1
                        elseif pyramid[y][x] < pyramid[y-1][x]
                            ind = x
                        end
                    elseif x <= y - 1 && pyramid[y][x] < pyramid[y-1][x]
                        ind = x
                    elseif 1 < x && pyramid[y][x] < pyramid[y-1][x-1]
                        ind = x - 1
                    end
                    if ind == -1
                        break
                    end
                    pyramid[y][x], pyramid[y-1][ind] = pyramid[y-1][ind], pyramid[y][x]
                    push!(ans, "$(y-1) $(x-1) $(y-2) $(ind-1)")
                    y, x = y - 1, ind
                    if length(ans) == 10000
                        return ans
                    end
                end
                while true
                    ind = -1
                    if y == 30
                        break
                    end
                    if pyramid[y+1][x] > pyramid[y+1][x+1] && pyramid[y][x] > pyramid[y+1][x]
                        ind = x + 1
                    elseif pyramid[y][x] > pyramid[y+1][x+1]
                        ind = x
                    end
                    if ind == -1
                        break
                    end
                    pyramid[y][x], pyramid[y+1][ind] = pyramid[y+1][ind], pyramid[y][x]
                    push!(ans, "$(y-1) $(x-1) $(y) $(ind-1)")
                    y, x = y + 1, ind
                    if length(ans) == 10000
                        return ans
                    end
                end
                flag = true
                break
            end
        end
    end
    ans
end

function solve2(n, l, pyramid)
    ans = []
    order = []
    for num = 0:l÷2-1
        push!(order, num)
        push!(order, l - num - 1)
    end
    for _ = 1:20
        for num = order
            flag = false
            for i = 1:n, j = 1:i
                if pyramid[i][j] != num
                    continue
                end
                y, x = i, j
                while true
                    ind = -1
                    if y == 1
                        break
                    end
                    if 1 < x && x <= y - 1
                        if pyramid[y-1][x] < pyramid[y-1][x-1] && pyramid[y][x] < pyramid[y-1][x-1]
                            ind = x - 1
                        elseif pyramid[y][x] < pyramid[y-1][x]
                            ind = x
                        end
                    elseif x <= y - 1 && pyramid[y][x] < pyramid[y-1][x]
                        ind = x
                    elseif 1 < x && pyramid[y][x] < pyramid[y-1][x-1]
                        ind = x - 1
                    end
                    if ind == -1
                        break
                    end
                    pyramid[y][x], pyramid[y-1][ind] = pyramid[y-1][ind], pyramid[y][x]
                    push!(ans, "$(y-1) $(x-1) $(y-2) $(ind-1)")
                    y, x = y - 1, ind
                    if length(ans) == 10000
                        return ans
                    end
                end
                while true
                    ind = -1
                    if y == 30
                        break
                    end
                    if pyramid[y+1][x] > pyramid[y+1][x+1] && pyramid[y][x] > pyramid[y+1][x]
                        ind = x + 1
                    elseif pyramid[y][x] > pyramid[y+1][x+1]
                        ind = x
                    end
                    if ind == -1
                        break
                    end
                    pyramid[y][x], pyramid[y+1][ind] = pyramid[y+1][ind], pyramid[y][x]
                    push!(ans, "$(y-1) $(x-1) $(y) $(ind-1)")
                    y, x = y + 1, ind
                    if length(ans) == 10000
                        return ans
                    end
                end
                flag = true
                break
            end
        end
    end
    ans
end

function solve3(n, l, pyramid)
    ans = []
    for h = 1:25
        if h % 2 == 1
            order = 0:l-1
        else
            order = l-1:-1:0
        end
        for num = order
            flag = false
            for i = 1:n, j = 1:i
                if pyramid[i][j] != num
                    continue
                end
                y, x = i, j
                while true
                    ind = -1
                    if y == 1
                        break
                    end
                    if 1 < x && x <= y - 1
                        if pyramid[y-1][x] < pyramid[y-1][x-1] && pyramid[y][x] < pyramid[y-1][x-1]
                            ind = x - 1
                        elseif pyramid[y][x] < pyramid[y-1][x]
                            ind = x
                        end
                    elseif x <= y - 1 && pyramid[y][x] < pyramid[y-1][x]
                        ind = x
                    elseif 1 < x && pyramid[y][x] < pyramid[y-1][x-1]
                        ind = x - 1
                    end
                    if ind == -1
                        break
                    end
                    pyramid[y][x], pyramid[y-1][ind] = pyramid[y-1][ind], pyramid[y][x]
                    push!(ans, "$(y-1) $(x-1) $(y-2) $(ind-1)")
                    y, x = y - 1, ind
                    if length(ans) == 10000
                        return ans
                    end
                end
                while true
                    ind = -1
                    if y == 30
                        break
                    end
                    if pyramid[y+1][x] > pyramid[y+1][x+1] && pyramid[y][x] > pyramid[y+1][x]
                        ind = x + 1
                    elseif pyramid[y][x] > pyramid[y+1][x+1]
                        ind = x
                    end
                    if ind == -1
                        break
                    end
                    pyramid[y][x], pyramid[y+1][ind] = pyramid[y+1][ind], pyramid[y][x]
                    push!(ans, "$(y-1) $(x-1) $(y) $(ind-1)")
                    y, x = y + 1, ind
                    if length(ans) == 10000
                        return ans
                    end
                end
                flag = true
                break
            end
        end
    end
    ans
end

function __main(my_stdin, my_stdout)
    redirect_stdin(my_stdin)
    redirect_stdout(my_stdout)
    n = 30
    l = 465
    pyramid = [int(inputs()) for _ = 1:n]
    ans = solve(n, l, deepcopy(pyramid))
    ans2 = solve2(n, l, deepcopy(pyramid))
    ans3 = solve2(n, l, deepcopy(pyramid))

    if min(length(ans), length(ans2), length(ans3)) == length(ans)
        println(length(ans))
        println.(ans)
    elseif min(length(ans), length(ans2), length(ans3)) == length(ans2)
        println(length(ans2))
        println.(ans2)
    else
        println(length(ans3))
        println.(ans3)
    end
end

function main()
    for file = 0:99
        fin = open("in/$(lpad(file,4,"0")).txt", "r")
        fout = open("out/$(lpad(file,4,"0")).txt", "w")
        __main(fin, fout)
        close(fin)
        close(fout)
    end
end

input() = readline()
inputs() = split(readline())
int(s::AbstractChar) = parse(Int, s)
int(s::AbstractString) = parse(Int, s)
int(v::AbstractArray) = map(x -> parse(Int, x), v)
isfile("myinput.txt") && (mystdin = open("myinput.txt", "r"); redirect_stdin(mystdin))
main()
@isdefined(mystdin) && close(mystdin)