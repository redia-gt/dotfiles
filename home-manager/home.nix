{homeUser, config, pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in

{
  home.username =homeUser;
  home.homeDirectory = (
     if isLinux then "/home/${homeUser}" else "/Users/${homeUser}"
  );

  home.stateVersion = "24.11"; # Please read the comment before changing.

  xdg.systemDirs.data = lib.mkIf isLinux [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  home.packages = with pkgs; [
    awscli2
    lazygit
    gh
    podman
    nixfmt-rfc-style
    jetbrains.datagrip
  ];

  home.file = { };

  services.podman = lib.mkIf isLinux {
    enable = true;
  };

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
  programs.starship = {
    enable = true;
  };
  programs.zoxide.enable = true;
  programs.keychain = {
    enable = true;
    keys = [
      "id_ed25519"
    ];
  };
  programs.git = {
    enable = true;
    userName = builtins.getEnv "GIT_USER";
    userEmail = builtins.getEnv "GIT_EMAIL";
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = builtins.getEnv "SSH_PUB_KEY";
    };
    aliases = {
      "subup" = "submodule update --init --recursive";
      "co" = "checkout";
      "cob" = "checkout -b";
      "br" = "branch";
      "st" = "status";
      "cm" = "commit -m";
      "amend" = "commit --amend -m";
      "po" = "push origin";
      "cp" = "cherry-pick";
      "rmcache" = "rm -rf --cached .";
      "gone" =
        "! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D";
    };
  };
}
