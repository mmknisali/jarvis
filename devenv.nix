# Jarvis DevEnv Configuration
# Usage:
#   devenv up                    # Just deps
#   devenv up                    # Then run commands below manually
#
# Commands (run inside devenv shell):
#   install-ollama   # Install Ollama
#   install-jarvis  # Clone Jarvis from fork
#   setup-models    # Configure small models for 940MX
#   start-ollama    # Start Ollama daemon
#   start-jarvis    # Run Jarvis
#   check-gpu       # Check GPU status

{ pkgs, lib, config, ... }:

let
  forkUrl = "git@github.com:mknisali/jarvis.git";
in
{
  dotenv.disableHint = true;

  # System dependencies
  nativeBuildInputs = with pkgs; [
    portaudio
    libEGL
    libxkbcommon
    ayatana-appindicator
    git
    curl
    wget
    vim
  ];

  # Python 3.11
  languages.python = {
    enable = true;
    package = pkgs.python311;
  };

  # Python packages from requirements.txt (server-side only, no desktop deps)
  packages = with pkgs.python311Packages; [
    python-dotenv
    flask
    requests
    beautifulsoup4
    lxml
    html2text
    playwright
    numpy
    faster-whisper
    sounddevice
    pytesseract
    Pillow
    webrtcvad
    rapidfuzz
    pynput
    geoip2
    miniupnpc
    pytest
    pytest-repeat
    piper-tts
    pygame
    faiss-cpu
  ];

  # Environment variables
  env = {
    PYTHONPATH = "${placeholder "out"}/src";
  };

  # Custom scripts/commands
  scripts = {
    check-gpu.exec = ''
      echo "🖥️  GPU Status:"
      if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv
      else
        echo "   nvidia-smi not found - NVIDIA driver may not be installed"
      fi
    '';

    install-ollama.exec = ''
      if command -v ollama &> /dev/null; then
        echo "✅ Ollama already installed: $(ollama --version)"
      else
        echo "📥 Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        echo "✅ Ollama installed"
      fi
    '';

    install-jarvis.exec = ''
      if [ -d "$HOME/jarvis" ]; then
        echo "📦 Updating Jarvis..."
        cd "$HOME/jarvis"
        git pull
      else
        echo "📦 Cloning Jarvis from fork..."
        git clone ${forkUrl} "$HOME/jarvis"
      fi

      echo "📦 Installing dependencies..."
      cd "$HOME/jarvis"
      pip install -r requirements.txt
      echo "✅ Jarvis ready at ~/jarvis"
    '';

    setup-models.exec = ''
      echo "⚙️  Configuring small models for 940MX"
      mkdir -p ~/.config/jarvis

      cat > ~/.config/jarvis/config.json << 'EOF'
{
  "whisper_model": "tiny",
  "ollama_chat_model": "llama3.2:1b"
}
EOF

      echo "✅ Config written to ~/.config/jarvis/config.json"
      echo ""
      echo "Settings:"
      echo "   whisper_model:     tiny (~1GB VRAM)"
      echo "   ollama_chat_model: llama3.2:1b (~2GB VRAM)"
    '';

    start-ollama.exec = ''
      if ! command -v ollama &> /dev/null; then
        echo "❌ Ollama not installed. Run: install-ollama"
        exit 1
      fi

      echo "🔮 Starting Ollama..."
      ollama serve &
      sleep 2

      if pgrep -x "ollama" > /dev/null; then
        echo "✅ Ollama running on http://localhost:11434"
      else
        echo "❌ Failed to start Ollama"
      fi
    '';

    start-jarvis.exec = ''
      if [ ! -d "$HOME/jarvis" ]; then
        echo "❌ Jarvis not installed. Run: install-jarvis"
        exit 1
      fi

      echo "🤖 Starting Jarvis..."
      cd "$HOME/jarvis"
      bash scripts/run_linux.sh
    '';
  };

  # Welcome banner on shell enter
  enterShell = ''
    cat << "EOF"

╔════════════════════════════════════════════════════════════╗
║              🤖 Jarvis DevEnv Ready                        ║
╚════════════════════════════════════════════════════════════╝

📍 Quick Setup (run in order):

   1. install-ollama   # Install Ollama (one-time)
   2. install-jarvis   # Clone Jarvis (one-time)
   3. setup-models     # Configure for 940MX (one-time)
   4. start-ollama     # Start Ollama
   5. start-jarvis     # Run Jarvis

📍 Current Status:
EOF

    echo -n "   🖥️  GPU: "
    if command -v nvidia-smi &> /dev/null; then
      nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo "unknown"
    else
      echo "not detected"
    fi

    echo -n "   🔮 Ollama: "
    if command -v ollama &> /dev/null; then
      echo "installed"
    else
      echo "not installed"
    fi

    echo -n "   🤖 Jarvis: "
    if [ -d "$HOME/jarvis" ]; then
      echo "installed"
    else
      echo "not installed"
    fi

    echo ""
  '';
}
