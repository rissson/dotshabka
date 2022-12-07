{
  # name = "soxincfg";

  description = "Lama Corp. infrastructure configurations.";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";

    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        deploy-rs.follows = "deploy-rs";
        flake-utils-plus.follows = "flake-utils-plus";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
        nur.follows = "nur";
        sops-nix.follows = "sops-nix";
      };
    };

    dns.url = "github:kirelagin/dns.nix";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self , nixpkgs , flake-utils-plus , soxin , ...  } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) optionalAttrs recursiveUpdate singleton;
      inherit (flake-utils-plus.lib) flattenTree exporter mkApp;
    in
    soxin.lib.mkFlake rec {
      inherit inputs;

      withDeploy = true; # deploy-rs support
      withSops = true; # sops-nix support

      nixosModules = (import ./modules) // {
        profiles = import ./profiles;
        soxin = import ./soxin/soxin.nix; # TODO: migrate those over to Soxin
        soxincfg = import ./modules/soxincfg.nix;
      };

      nixosModule = self.nixosModules.soxincfg;

      extraGlobalModules = [
        self.nixosModule
        self.nixosModules.profiles.core
        self.nixosModules.soxin
      ];

      extraNixosModules = [
        inputs.impermanence.nixosModules.impermanence
      ];

      globalSpecialArgs = {
        inherit inputs;
        userName = "risson";
      };

      hostDefaults = {
        channelName = "nixpkgs";
      };
      hosts = import ./hosts inputs;

      home-managers = import ./home-managers inputs;

      vars = import ./vars;

      channelsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "ferdi-5.8.1"
        ];
      };

      sharedOverlays = [
        (import "${inputs.docker-nixpkgs}/overlay.nix")
      ];

      channels = {
        nixpkgs = {
          overlaysBuilder = channels: [
            (final: prev: {
              inherit (channels.nixpkgs-unstable)
                awscli
                claws-mail
                chromium
                element-desktop
                ferdi
                firefox
                mr
                nixpkgs-fmt
                nixpkgs-review
                s3cmd
                slack
                spotify
                steam
                teams
                terraform
                thunderbird
                tmuxp
                vault
                vault-bin
                vlc
                warsow
              ;
              inherit (channels.nixpkgs-master)
                discord
              ;
            })
          ];
        };
        nixpkgs-master.input = inputs.nixpkgs-master;
      };

      outputsBuilder = channels: {
        apps = with channels.nixpkgs;
          let
            hostList = builtins.attrNames self.nixosConfigurations;
            pkgList = builtins.attrNames (lib.filterAttrs (name: _: !lib.hasSuffix "-docker" name) self.packages.${system});
            mkListApp = list: {
              type = "app";
              program = toString (writeShellScript "list.sh" (lib.concatMapStringsSep "\n" (el: "echo '${el}'") list));
            };
          in
          {
            list-hosts = mkListApp hostList;
            list-pkgs = mkListApp pkgList;

            awscli = mkApp {
              drv = awscli;
              exePath = "/bin/aws";
            };
            nix-diff = mkApp {
              drv = channels.nixpkgs-master.nix-diff;
            };
            nixpkgs-fmt = mkApp {
              drv = nixpkgs-fmt;
            };
            skopeo = mkApp {
              drv = skopeo;
            };
          };

        devShell = with channels.nixpkgs; mkShell {
          buildInputs = [
            git
            vault
            terraform
          ];

          shellHook = ''
            eval "$(cat config.sh)"
          '';
        };

        packages = flattenTree (import ./pkgs channels);
      };
    };
}
