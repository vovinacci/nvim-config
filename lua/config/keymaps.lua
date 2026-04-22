local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down + center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up + center" })
map("n", "n", "nzzzv", { desc = "Next match + center" })
map("n", "N", "Nzzzv", { desc = "Prev match + center" })

map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

map("v", "<", "<gv", { desc = "Outdent and reselect" })
map("v", ">", ">gv", { desc = "Indent and reselect" })

map({ "n", "i", "x" }, "<C-s>", "<cmd>write<CR>", { desc = "Save" })

map("n", "<leader>ws", "<C-w>s", { desc = "Split window" })
map("n", "<leader>wv", "<C-w>v", { desc = "Vsplit window" })
map("n", "<leader>wc", "<C-w>c", { desc = "Close window" })
