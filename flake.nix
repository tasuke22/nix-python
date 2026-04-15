{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      flake-parts,
      git-hooks,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              ruff-check.enable = true;
              ruff-format.enable = true;
            };
            settings.formatter.oxfmt = {
              command = "${pkgs.oxfmt}/bin/oxfmt";
              options = [ "--no-error-on-unmatched-pattern" ];
              includes = [ "*.md" ];
            };
          };

          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              gitleaks = {
                enable = true;
                name = "gitleaks";
                entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --config .gitleaks.toml";
                language = "system";
                pass_filenames = false;
              };
              treefmt = {
                enable = true;
                package = treefmtEval.config.build.wrapper;
              };
              ty = {
                enable = true;
                name = "ty";
                entry = "${pkgs.ty}/bin/ty check";
                files = "^src/";
                language = "system";
                types = [ "python" ];
              };
            };
          };
        in
        {
          formatter = treefmtEval.config.build.wrapper;

          devShells.default = pkgs.mkShellNoCC {
            buildInputs = with pkgs; [
              uv
              ty
              just
              ruff
              gitleaks
            ];

            env.PYTHONBREAKPOINT = "pudb.set_trace";

            shellHook = ''
              if [ ! -d .venv ] || [ uv.lock -nt .venv ]; then
                echo "Installing Python dependencies..."
                uv sync --locked 2>/dev/null || uv sync
              fi

              ${pre-commit-check.shellHook}
            '';
          };
        };
    };
}
