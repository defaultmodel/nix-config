## Nix-OS anywhere
[Quickstart](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md)

```
  nix --extra-experimental-features nix-command --extra-experimental-features flake run github:nix-community/nixos-anywhere -- --disko-mode disko --flake .#<hostname> --target-host nixos@<host ip>
```
