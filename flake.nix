{
  description = "VSCode Patch Experiment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/3bcedce9f4de37570242faf16e1e143583407eab";

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };

      patchedVscode = pkgs.vscode.overrideAttrs (oldAttrs: {
        vscodeWithExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "apc-extension";
            publisher = "drcika";
            version = "0.3.9";
            sha256 = "sha256-VMUICGvAFWrG/uL3aGKNUIt1ARovc84TxkjgSkXuoME=";
          }
        ];

        postPatch = oldAttrs.postPatch or "" + ''
          cp "${./patch-vscode.sh}" $TMPDIR/patch-vscode.sh
          chmod +x $TMPDIR/patch-vscode.sh

          cp -r "$vscodeWithExtensions/share/vscode/extensions/drcika.apc-extension/." "$TMPDIR/extension/"

          $TMPDIR/patch-vscode.sh "$TMPDIR/extension" "Contents/Resources/app/out"
        '';
      });

    in {
      packages.aarch64-darwin.default = patchedVscode;
    };
}
