local M = { }

--> diagnostics fix
vim = vim

local types = { "neofetch", "fastfetch", "pfetch" }

local function pull_output(fetch_type)
    local handle = io.popen(fetch_type)
    if handle == nil then return end

    local result = handle:read("*a")
    handle:close()

    --> strip ansi
    result = result:gsub('\27%[[%d;]*m', '')
    result = result:gsub('\27%[[%d;]*[A-Z]', '')
    result = result:gsub('\27%[%?%d+[hl]', '')

    --> convert into blow
    local blow = { }
    for line in result:gmatch("[^\r\n]+") do
        table.insert(blow, line)
    end

    return blow
end

local function create_window(output)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    local width = 50
    local height = 10
    local row = (vim.o.lines - height) / 2
    local col = (vim.o.columns - width) / 2

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    })
end

function M.setup(opts)
    opts = opts or { }

    vim.api.nvim_create_user_command('Nfetch', function()
        if opts.type then
            local output = pull_output(opts.type)
            create_window(output)
        else
            local output = pull_output("fastfetch")
            create_window(output)
        end
    end, {})
end

return M
