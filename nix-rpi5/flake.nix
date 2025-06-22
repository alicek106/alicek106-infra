{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixvim,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        homeDir = "/home/alicek106";

        pkgs = import nixpkgs { inherit system; };

        nvim = nixvim.legacyPackages.${system}.makeNixvim {
          extraConfigVim = builtins.readFile ./nvimrc.vim;
          extraConfigLua = builtins.readFile ./nvim.init.lua;
          extraPlugins = with pkgs.vimPlugins; [
            lazy-nvim
            conform-nvim
            vim-airline
            fzf-vim
            vim-lastplace
            nerdtree
            nvim-osc52
          ];

          extraPackages = [ pkgs.nixfmt-rfc-style ];
        };

        k3sServiceTemplate = builtins.readFile ./k3s-template.service;
        k3sServiceContent =
          builtins.replaceStrings [ "K3S_BINARY" "HOME_DIR" ] [ "${pkgs.k3s}/bin/k3s" "${homeDir}" ]
            k3sServiceTemplate;
        k3sServiceFile = pkgs.writeText "k3s.service" k3sServiceContent;
      in
      {
        packages.${system}.default = nvim;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            nvim
            pkgs.zsh
            pkgs.zimfw
            pkgs.fzf
            pkgs.zsh-completions
            pkgs.zsh-autosuggestions
            pkgs.zsh-syntax-highlighting
            pkgs.k3s_1_30
            pkgs.k3s
            pkgs.ripgrep
            pkgs.kubectx
            pkgs.buildkit
          ];

          shellHook = ''
            export ZDOTDIR=${homeDir}/nix
            export ZIM_HOME=${homeDir}/nix-data/zim
            mkdir -p $ZIM_HOME

            export ZIM_INIT=${pkgs.zimfw}/zimfw.zsh
            export FZF=${pkgs.fzf}

            mkdir -p ${homeDir}/nix-data/k3s/systemd
            cp ${k3sServiceFile} ${homeDir}/nix-data/k3s/systemd/k3s.service

            echo "Run 'systemctl enable ${homeDir}/nix-data/k3s/systemd/k3s.service' to enable."

            exec ${pkgs.zsh}/bin/zsh
          '';
        };
      }
    );
}
