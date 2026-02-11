{pkgs, ...}: {
  home.username = "titan";
  home.homeDirectory = "/home/titan";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "vandy135";
      user.email = "titan@fob-aspen";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
      pull.rebase = false;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      extraOptions.AddKeysToAgent = "yes";
      identityFile = [ "~/.ssh/github" ];
    };
  };

  home.stateVersion = "25.11";
}
