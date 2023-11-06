function f()
    for seed = 0:99
        filename = lpad(seed, 4, "0")
        intxt = joinpath(abspath(@__DIR__), "in\\$filename.txt")
        outtxt = joinpath(abspath(@__DIR__), "out\\$filename.txt")
        # @show filename
        run(`./vis.exe $intxt $outtxt`)
    end
end
f()