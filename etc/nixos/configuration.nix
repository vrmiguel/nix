# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader configs
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "pepsi-twist";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  # Locale configs
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Get Bluetooth working, hopefully
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "br";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vrmiguel = {
    isNormalUser = true;
    description = "Vinícius R. Miguel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      rustup
      tdesktop
      spotify
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow firmware with licenses that allow redistribution
  hardware.enableRedistributableFirmware = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # HW-probing
    inxi
    pciutils # Provides lspci

    # Text editor
    helix

    # Image editing
    gmic
    gmic-qt
    (gimp-with-plugins.override { plugins = with gimpPlugins; [ gmic ]; })
    rawtherapee

    # Git-related
    gh
    git
    sublime-merge

    # Password management
    keepassxc

    # C++ and further compilation stuff
    binutils
    clang
    qtcreator
    
    (vscode-with-extensions.override {
         vscodeExtensions = with vscode-extensions; [
             rust-lang.rust-analyzer
             ms-python.python
             bbenoist.nix
         ];
    })

    # X11 stuff
    xclip

    # Totally not piracy
    qbittorrent
    stremio
  ];


  environment = {
    homeBinInPath = true;
    variables = {
      PATH = "$HOME/.cargo/bin";
      VISUAL = "vscode";
      EDITOR = "hx";
      RUST_BACKTRACE = "short";
    };
  };

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      hack-font
      fira-code
      ubuntu_font_family
      inconsolata
      noto-fonts
      noto-fonts-emoji
      jetbrains-mono
      julia-mono
    ];
  };

  # Swap compression configs
  zramSwap.enable = true;
  zramSwap.memoryPercent = 150;
  boot.kernel.sysctl."vm.swappiness" = 190;


  system.stateVersion = "22.11";
}
