# ASUS ProArt PX13 (HN7306WU) platform support — convertible, AMD Strix Point.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # asusctl userspace: N-KEY keyboard backlight / Aura, fan curves, platform
  # profiles, battery-charge control (`asusctl -c <pct>`).
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # AMD laptop power management. amd_pmf exposes the platform profile that
  # power-profiles-daemon drives; ppd is what the niri/waybar power menu expects.
  # ppd is mutually exclusive with TLP — leave TLP off.
  services.power-profiles-daemon.enable = true;

  # Convertible / 2-in-1 sensors: accelerometer (screen auto-rotation) + ambient
  # light. iio-sensor-proxy exposes them; iio-niri applies orientation to niri.
  hardware.sensor.iio.enable = true;
  services.iio-niri.enable = true;

  # Sound Open Firmware for the AMD ACP audio DSP. NOTE: the internal speakers
  # use Cirrus CS35L41 smart amps and are the feature most likely to need extra
  # work on first boot — verify with `aplay -l` / `speaker-test` after install
  # (headphones and HDMI/DP audio work regardless).
  hardware.firmware = [ pkgs.sof-firmware ];
}
