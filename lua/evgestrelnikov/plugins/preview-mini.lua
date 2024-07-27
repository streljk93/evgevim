return {
	"kevinhwang91/nvim-bqf",
	config = function()
		require("bqf").setup({
			preview = {
				win_height = 999,
				winblend = 0,
			},
		})
	end,
}
