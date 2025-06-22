{
  description = "alicek106 rpi flake.nix. TODO: migrate settings to home.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      ...
    }:
    let
      system = "aarch64-linux";
      homeDir = "/root";
      pkgs = import nixpkgs { inherit system; };

      k3sServiceTemplate = builtins.readFile ./k3s-template.service;
      k3sServiceContent =
        builtins.replaceStrings [ "K3S_BINARY" "HOME_DIR" ] [ "${pkgs.k3s}/bin/k3s" "${homeDir}" ]
          k3sServiceTemplate;
      k3sServiceFile = pkgs.writeText "k3s.service" k3sServiceContent;
    in
    {
      homeConfigurations.alicek106 = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          neovim
          zsh
          zimfw
          fzf
          zsh-completions
          zsh-autosuggestions
          zsh-syntax-highlighting
          k3s
          ripgrep
          kubectx
          buildkit
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
    };
}
