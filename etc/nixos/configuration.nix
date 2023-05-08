# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  running-on-wayland = false;
  running-on-xorg = !running-on-wayland;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader configs
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "pepsi-twist";
  

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking = {
    wireless.iwd.enable = true;

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
  

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

  # Configuring home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # home-manager option docs: https://nix-community.github.io/home-manager/options.html
  home-manager.users.vrmiguel = { config, pkgs, ... }: {
    xsession.enable = running-on-xorg;

    wayland.windowManager.sway = {
      enable = running-on-wayland;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty"; 
        startup = [
          # Launch Firefox on start
          {command = "firefox";}
        ];
      };
    };

    programs.i3status-rust = {
      enable = running-on-wayland;
      # systemd.enable = true;
      #icons = "awesome5";
      #theme = "gruvbox-dark";
    };



    # services.sxhkd.enable = true;
    # services.sxhkd.keybindings = {
    #   "ctrl + alt + t" = "alacritty";
    #   "print" = "flameshot --gui -c";
    # };
    # services.sxhkd.extraOptions = [ "-c ~/.config/sxhkd/sxhkdrc" ];
    # services.screen-locker.xautolock.enable = true;
    # 
    # services.screen-locker.lockCmd = "i3lock -d -c 000070";

    services.screen-locker = {
      inactiveInterval = 1; # 1 min
      enable = true;
      xautolock.enable = false;
      xss-lock.extraOptions = [
        "-n ${pkgs.xsecurelock}/libexec/dimmer"
        "-l"
      ];
      lockCmd =  "${pkgs.xsecurelock}/bin/xsecurelock";
    };
    services.network-manager-applet.enable = true;

    services.picom = {
      enable = running-on-xorg;
      fade = true;
      fadeDelta = 3;
      vSync = true;
    };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      history = {
        # Save timestamps on zsh history
        extended = true;
        ignoreDups = true;
        share = true;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" ];
        theme = "amuse";
      };

      # prezto = {
      #   enable = true;
      #   caseSensitive = false;
      # };
    };

    programs.rofi = {
      enable = true;
      location = "bottom-left";
      theme = "purple";
      plugins = [ pkgs.rofi-calc ];
    };
    
    programs.starship.enable = true;
    programs.starship.settings = {
      character = {
        error_symbol = "[❯](bold red)";
        success_symbol = "[❯](bold grey)";
      };
    };

    programs.starship.enableFishIntegration = true;
    programs.starship.enableZshIntegration = true;
    programs.starship.enableIonIntegration = false;
    programs.starship.enableBashIntegration = false;

    home.stateVersion = "22.11";
  };

  # WM/DE config
  services.xserver = {
    # Enable the X11 windowing system.
    enable = running-on-xorg;

    displayManager = {
      sddm.enable = running-on-xorg;
      defaultSession = "plasma";
    };

    windowManager.awesome = {
      enable = running-on-xorg;
      luaModules = with pkgs.luaPackages; [
        luarocks # is the package manager for Lua modules
        luadbi-mysql # Database abstraction layer
      ];
    };

    desktopManager = { 
      plasma5.enable = true;
      xterm.enable = true;
    };
  };
  
  # For brightness control
  programs.light.enable = true;

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
  services.printing.enable = false;

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

  # Enable touchpad support (enabled default in most desktop managers).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vrmiguel = {
    isNormalUser = true;
    description = "Vinícius R. Miguel";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
      google-chrome
      tdesktop
      slack
      spotify
      steam
    ];
  };

  programs.steam.enable = true;
  programs.xwayland.enable = running-on-wayland;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow firmware with licenses that allow redistribution
  hardware.enableRedistributableFirmware = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wgetq
  environment.systemPackages = with pkgs; [
    # HW-probing
    inxi
    pciutils # Provides lspci
    arandr

    # Text editors
    helix
    lapce
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        rust-lang.rust-analyzer
        ms-python.python
        ms-vsliveshare.vsliveshare
        bbenoist.nix
        sumneko.lua
      ];
    })
 
    # Blazingly fast hardware-accelerated blazingly fast safe Rust terminal
    alacritty
    kitty

    # Image editing
    #gmic
    #gmic-qt
    gwenview
    # (gimp-with-plugins.override { plugins = with gimpPlugins; [ gmic ]; })
    rawtherapee

    # Git-related
    gh
    git
    sublime-merge

    # Password management
    keepassxc
    # authenticator # Gnome Authenticator

    binutils

    # Programming
    gcc
    clang
    rustup
    qtcreator
    (python3.withPackages (py: [py.pandas py.requests]))
    ghc
    postman
    openssl
    openssl.dev
    pkg-config
    musl
    protobuf    

    # GUI for sound control
    pavucontrol

    # Video
    mpv
    youtube-dl

    # X11 stuff
    xclip
    xorg.xev
    kwin

    # Totally not piracy
    qbittorrent
    stremio

    # Screenshot
    flameshot

    # The home-manager binary
    home-manager
    
    # PDF reader
    evince

    # Lockscreen
    xsecurelock

    # Compression/decompression
    ouch
    libzip
    zlib

    # File manager
    # thunar
  ];

  environment = {
    homeBinInPath = true;
    pathsToLink = [ "/share/zsh" ];
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

  # Config Nix's GC
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "22.11";
}
