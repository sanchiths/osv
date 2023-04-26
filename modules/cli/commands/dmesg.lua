local cmd = {}

cmd.desc = [[print operating system boot log]]
cmd.help = [[Usage: dmesg
Print operating system boot log.]]

cmd.main = function()
    local content, status = osv_request({"os", "dmesg"}, "GET")
    osv_resp_assert(status, 200)

    -- Split the content by newline to get an array of lines
    local lines = {}
    for line in content:gmatch("([^\n]*)\n") do
        table.insert(lines, line)
    end

    -- Add timestamp to each line and print the result
    for _, line in ipairs(lines) do
        -- Get the current timestamp in seconds since the epoch
        local timestamp = os.time()

        -- Format the timestamp as a human-readable string
        local formatted_timestamp = os.date("%Y-%m-%d %H:%M:%S", timestamp)

        -- Print the line with the timestamp prefix
        io.write(formatted_timestamp .. " " .. line .. "\n")
    end
end

return cmd
