{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "juan";
  home.homeDirectory = "/home/juan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    awscli2
    lazygit
    gh
    podman
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/juan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
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
   "id_ed25519_finanssoreal"
  ];
  };
programs.git = {
      enable = true;
      userName = "JuanAntonioSantiago015";
      userEmail = "juanantoniosantiago92@gmail.com";
      extraConfig = {
        # Sign all commits using ssh key
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
        "gone" = "! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D";
        "rmcache" = "rm -rf --cached .";
    
      };
    
    };
}
