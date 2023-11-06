for i = 0:99
    run(`./vis.exe in/$(lpad(i,4,"0")).txt out/$(lpad(i,4,"0")).txt`)
end