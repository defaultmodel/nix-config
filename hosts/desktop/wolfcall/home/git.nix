{ ... }: {
  programs.git = {
    enable = true;
    userName = "Hilan Meyran";
    userEmail = "hilanmeyran@protonmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      merge.conflictstyle = "zdiff3";
    };
  };
}
