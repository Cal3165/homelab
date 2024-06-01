{
  description = "Homelab";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    krew2nix.url = "github:eigengrau/krew2nix";
    krew2nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, krew2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # TODO remove unfree after removing Terraform
        # (Source: https://xeiaso.net/blog/notes/nix-flakes-terraform-unfree-fix)
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        kubectl = krew2nix.packages.${system}.kubectl;
      in
      with pkgs;
      {
        devShells.default = mkShell {
          packages = [
            ansible
            ansible-lint
            bmake
            diffutils
            docker
            docker-compose_1 # TODO upgrade to version 2
            dyff
            git
            go
            gotestsum
            iproute2
            jq
            k9s
            kanidm
            kube3d
            kubernetes-helm
            kustomize
            libisoburn
            neovim
            openssh
            p7zip
            pre-commit
            shellcheck
            terraform # TODO replace with OpenTofu, Terraform is no longer FOSS
            yamllint
            
            (kubectl.withKrewPlugins (plugins: [
              plugins.oidc-login
            ]))

            (python3.withPackages (p: with p; [
              jinja2
              kubernetes
              mkdocs-material
              netaddr
              pexpect
              rich
            ]))
          ];
        };
      }
    );
}
