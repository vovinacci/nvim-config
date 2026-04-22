local EXCLUDES = {
  ".git", "target", "node_modules", "vendor",
  ".terraform", "dist", "build", "*.min.js",
}

local function fd_excludes()
  local out = {}
  for _, p in ipairs(EXCLUDES) do
    table.insert(out, "--exclude")
    table.insert(out, p)
  end
  return table.concat(out, " ")
end

local function rg_globs()
  local out = {}
  for _, p in ipairs(EXCLUDES) do
    table.insert(out, "--glob=!" .. p)
  end
  return table.concat(out, " ")
end

local function project_picker()
  local roots = vim.g.project_roots or { vim.fn.expand("~/src") }
  local seen, projects = {}, {}
  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then
      local out = vim.fn.systemlist({
        "fd", "--type", "d", "--hidden", "-d", "4", "^\\.git$", root,
      })
      for _, gitdir in ipairs(out) do
        local proj = vim.fs.dirname(gitdir)
        if not seen[proj] then
          seen[proj] = true
          table.insert(projects, proj)
        end
      end
    end
  end
  table.sort(projects)
  require("fzf-lua").fzf_exec(projects, {
    prompt = "Project> ",
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then return end
        local target = selected[1]
        pcall(function() require("neo-tree.command").execute({ action = "close" }) end)
        vim.api.nvim_set_current_dir(target)
        -- TODO Phase 7: require("persistence").load()
        vim.schedule(function()
          pcall(function() require("neo-tree.command").execute({ action = "show" }) end)
          vim.notify("cwd: " .. target, vim.log.levels.INFO)
        end)
      end,
    },
  })
end

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Files" },
      { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Buffers" },
      { "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Recent files" },
      { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "Grep word" },
      { "<leader>fd", function() require("fzf-lua").diagnostics_workspace() end, desc = "Diagnostics" },
      { "<leader>fp", project_picker, desc = "Projects" },
    },
    opts = {
      defaults = {
        formatter = "path.filename_first",
      },
      files = {
        fd_opts = table.concat({
          "--color=never",
          "--type=f",
          "--hidden",
          "--follow",
          fd_excludes(),
        }, " "),
      },
      grep = {
        rg_opts = table.concat({
          "--column",
          "--line-number",
          "--no-heading",
          "--color=always",
          "--smart-case",
          "--max-columns=4096",
          "--hidden",
          rg_globs(),
        }, " "),
      },
    },
  },
}
