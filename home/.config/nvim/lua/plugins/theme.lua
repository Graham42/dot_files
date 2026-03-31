return {
  'oxfist/night-owl.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('night-owl').setup()
    vim.cmd('colorscheme night-owl')

    -- Accessibility fixes
    -- Line numbers: #444444 → #7e7e7e (1.88:1 FAIL → 4.6:1 WCAG AA pass)
    vim.api.nvim_set_hl(0, 'LineNr', { fg = '#7e7e7e' })
    -- MatchParen: underline only (no garish background)
    vim.api.nvim_set_hl(0, 'MatchParen', { underline = true })
  end,
}
