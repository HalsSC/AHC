const n = 200
const m = 10
start_time = time()
const wait_time = 1.81

function solve(b, num)
    min_max = 1
    minval = 0
    for yama = 1:m
        min_ = 100000
        for hako = 1:length(b[yama])
            min_ = min(min_, b[yama][hako])
        end
        if minval > min_
            min_max = yama
            minval = min_
        end
    end
    for yama = 1:m
        for hako = 1:length(b[yama])
            if num == b[yama][hako]
                if hako < length(b[yama])
                    next = min_max == yama ? (yama) % m + 1 : min_max
                    println("$(b[yama][hako+1]) $(next)")
                    append!(b[next], b[yama][hako+1:end])
                    b[yama] = b[yama][1:hako]
                end
                pop!(b[yama])
                println("$num 0")
                return
            end
        end
    end
end


function main()
    _, _ = int(inputs())
    b = [int(inputs()) for _ = 1:m]
    for num = 1:n
        solve(b, num)
    end
    return 0
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