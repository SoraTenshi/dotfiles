{ pkgs, lib, config, inputs, ... }:

let
  swaylock = lib.getExe pkgs.swaylock-effects;
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  light = lib.getExe pkgs.light;
in {
  imports = [
    ./hyprland.nix
    ./eww.nix
    ./wofi.nix
    ./dunst.nix
    ./alacritty.nix
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    bitwarden
    brightnessctl
    discord
    element-desktop
    imv
    pavucontrol
    pinentry-gtk2
    slurp
    grim
    wl-clipboard
    wlr-randr
  ];

  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      {
        event = "before-sleep";
        command = "${loginctl} lock-session";
      }
      {
        event = "lock";
        command = "${swaylock} -efu -i ${inputs.self}/images/lock.png";
      }
      {
        event = "after-resume";
        command = "${hyprctl} dispatch dpms on";
      }
    ];
    timeouts = [
      {
        timeout = 150;
        command = "${light} -O; ${light} -T 0.25";
        resumeCommand = "${light} -I";
      }
      {
        timeout = 300;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
      {
        timeout = 360;
        command = "${loginctl} lock-session";
      }
      {
        timeout = 600;
        command = "${systemctl} suspend";
      }
    ];
  };
}
