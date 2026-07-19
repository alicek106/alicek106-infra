# home.nix
{ pkgs, ... }:

{
  home.username = "root";
  home.homeDirectory = "/root";

  home.packages = [
    pkgs.nixfmt-rfc-style # or pkgs.nixfmt-classic
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./nvimrc.vim;
    extraLuaConfig = builtins.readFile ./nvim.init.lua;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      conform-nvim
      vim-airline
      fzf-vim
      vim-lastplace
      nerdtree
      nvim-osc52
    ];
  };

  home.stateVersion = "24.11";
}
