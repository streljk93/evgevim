return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				path_display = { "truncate" },
				layout_config = {
					width = { padding = 0 },
					height = { padding = 0 },
				},
			},
		})

		telescope.load_extension("fzf")

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

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fg", "<cmd>Telescope git_status<cr>", { desc = "Fuzzy find git status files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

		keymap.set("v", "<leader>f", function()
			local text = vim.getVisualSelection()
			builtin.live_grep({ default_text = text })
		end)

		-- Функция для получения подмассивов и конкатенации их в строки
		local function get_sublists(array, start_idx, end_idx)
			local result = {}
			for i = start_idx, end_idx do
				local subarray = {}
				for j = i, end_idx do
					table.insert(subarray, array[j])
				end
				-- Конкатенируем подмассив в строку и добавляем в результат
				table.insert(result, table.concat(subarray, "/"))
			end
			return result
		end

		-- Получение относительного пути от последней директории
		local function get_relative_path_from_last_dir()
			local filepath = vim.fn.expand("%:p")
			local cwd = vim.fn.getcwd()
			local last_dir = vim.fn.fnamemodify(cwd, ":t")
			local pattern = "/" .. last_dir .. "/"
			local start_idx = filepath:find(pattern, 1, true)

			local relative_path
			if start_idx then
				relative_path = filepath:sub(start_idx + #pattern)
			else
				relative_path = filepath
			end

			-- Удаляем index.extension, если он есть
			local index_pattern = "/index%.%w+$"
			relative_path = relative_path:gsub(index_pattern, "")

			-- Удаляем .extension, если он есть
			index_pattern = "%.%w+$"
			relative_path = relative_path:gsub(index_pattern, "")

			return relative_path
		end

		-- Формирование поискового паттерна
		local function generate_search_pattern()
			local project_path = get_relative_path_from_last_dir()
			local parts = vim.split(project_path, "/")
			local count = #parts
			local pattern_parts = {}

			-- Формируем паттерны для всех подмассивов
			for i = 1, count do
				local sub = get_sublists(parts, i, count)
				for _, subpath in ipairs(sub) do
					-- Добавляем каждый путь в паттерн, учитывая возможный файл в конце
					table.insert(pattern_parts, "(?:@\\w*/|..?/)" .. subpath)
				end
			end

			-- Удаляем дублирующиеся паттерны
			local unique_pattern_parts = {}
			local pattern_set = {}
			for _, pattern in ipairs(pattern_parts) do
				if not pattern_set[pattern] then
					pattern_set[pattern] = true
					table.insert(unique_pattern_parts, pattern .. "\\b")
				end
			end

			-- Формируем окончательный паттерн с использованием (?: ... ) и |
			local pattern = "(?:" .. table.concat(unique_pattern_parts, "|") .. ")"

			-- import.*?(?:/*.+*/ )?['\"]
			return pattern .. "['\"]"
		end

		-- Функция экранирования для регулярного выражения
		local function escape_pattern(text)
			return text:gsub("([%/%.])", "\\%1")
		end

		-- Настройка привязки клавиш
		keymap.set("n", "gl", function()
			local search_pattern = escape_pattern(generate_search_pattern())
			builtin.live_grep({
				default_text = search_pattern,
				additional_args = function()
					return { "--glob", "!node_modules/**", "--glob", "!.git/**", "--glob", "!package-lock.json" }
				end,
			})
		end, { noremap = true, silent = true })

		-- Function to search for library usage from package.json
		-- local function search_library_usage()
		-- 	local current_line = vim.api.nvim_get_current_line()
		-- 	local cursor_pos = vim.api.nvim_win_get_cursor(0)
		-- 	local col = cursor_pos[2]
		--
		-- 	local pattern = '"([^"]+)":'
		-- 	local start_pos, end_pos = 0, 0
		-- 	for name in current_line:gmatch(pattern) do
		-- 		start_pos, end_pos = string.find(current_line, '"' .. name .. '":')
		-- 		if start_pos and col >= start_pos and col <= end_pos then
		-- 			builtin.live_grep({
		-- 				default_text = name,
		-- 				additional_args = function()
		-- 					return { "--glob", "!node_modules/**", "--glob", "!.git/**", "--glob", "!package-lock.json" }
		-- 				end,
		-- 			})
		-- 			return
		-- 		end
		-- 	end
		--
		-- 	print("No library found under cursor")
		-- end
		--
		-- -- Keymap to search for library usage
		-- keymap.set("n", "<leader>pl", search_library_usage, { desc = "Find library usage in project" })
	end,
}
