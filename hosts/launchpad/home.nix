{pkgs, ...}: {
  home.username = "titan";
  home.homeDirectory = "/home/titan";

  programs.home-manager.enable = true;

  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.05";
}
