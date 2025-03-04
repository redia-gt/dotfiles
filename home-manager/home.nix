{ config, pkgs, ... }:

{
  home.username = "$USER";
  home.homeDirectory = "/home/$USER";

  home.stateVersion = "24.11"; # Please read the comment before changing.
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  home.packages = with pkgs; [
    awscli2
    lazygit
    gh
    podman
    nixfmt-rfc-style
    jetbrains.datagrip
  ];

  home.file = { };

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:$XDG_DATA_DIRS";
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
    userName = ${GIT_USER};
    userEmail = ${GIT_EMAIL};
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmmPTB06PiqnXWbpnaldS/X8B+SM2ps/384Yp+qWI4h juanantoniosantiago92@gmail.com";
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
