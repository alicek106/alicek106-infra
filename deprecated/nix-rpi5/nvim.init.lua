require("conform").setup({
  formatters_by_ft = {
    nix = { "nixfmt" },
  },
  format_on_save = {
    lsp_fallback = true,
  },
})

require("osc52").setup({
  max_length = 0,
  trim = false,
  silent = false,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    if vim.v.event.operator == 'y' and vim.v.event.regname == "" then
      require("osc52").copy_register("")
    end
  end,
})
