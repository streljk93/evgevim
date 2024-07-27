return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gl", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		},
	},
	{
		"sindrets/diffview.nvim",
		config = function()
			function vim.getVisualSelection()
				vim.cmd('noau normal! "vy"')
				local text = vim.fn.getreg("v")
				vim.fn.setreg("v", {})

				text = string.gsub(text, "\n", "")
				if #text > 0 then
					return text
				else
					return ""
				end
			end
			vim.keymap.set("n", "<leader>g1", function()
				-- vim.cmd.normal("<cmd>Gitsigns blame_line")
				vim.api.nvim_command(":Gitsigns blame_line")
				vim.wait(100, function() end)
				vim.api.nvim_command(":wincmd w")
				vim.cmd.normal("v")
				vim.cmd.normal("e")
				-- vim.cmd.normal("y")
				-- vim.cmd.normal("q")
				local text = vim.getVisualSelection()
				-- or use api.nvim_buf_get_lines
				-- local lines = vim.fn.getline(line_start, line_end)
				vim.api.nvim_command(":DiffviewOpen " .. text .. " -- %")
				-- vim.cmd.normal("<C-w>w")
				-- vim.cmd.visual("e")
				-- vim.cmd.normal("DiffviewOpen")
			end, { desc = "Get last diff current file" })
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gB", ":Git blame<CR>", { desc = "Blame" })
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = true,
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				map("n", "g]", gs.next_hunk, "Next Hunk")
				map("n", "g[", gs.prev_hunk, "Prev Hunk")

				-- Actions
				map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>gs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk")
				map("v", "<leader>gr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk")

				map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")

				map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")

				map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")

				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
				-- map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")

				map("n", "<leader>gD", gs.diffthis, "Diff this")
				-- map("n", "<leader>g`", function()
				-- 	gs.diffthis("~")
				-- end, "Diff this ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
			end,
		},
	},
}
