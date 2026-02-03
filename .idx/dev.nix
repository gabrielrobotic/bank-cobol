{ pkgs, ... }: {
  channel = "stable-25.05";
  packages = with pkgs; [
    zsh
    gnu-cobol
  ];
  env = { };
  idx = {
    extensions = [
      "google.gemini-cli-vscode-ide-companion"
    ];
    previews = {
      enable = true;
      previews = { };
    };
    workspace = {
      onCreate = {
        default.openFiles = [ ".idx/dev.nix" "README.md" ];

        zsh_cobol-setup = ''
          echo "🔧 Inicializando ambiente Zsh + GnuCOBOL"

          # --- Garantir HOME consistente ---
          if [ -z "$HOME" ] || [ ! -d "$HOME" ]; then
            export HOME="/home/user"
          fi

          echo "HOME = $HOME"
          ls -ld "$HOME" || true

          # --- Oh My Zsh ---
          export RUNZSH=no
          export CHSH=no

          OHMYZSH="$HOME/.oh-my-zsh"
          ZSHRC="$HOME/.zshrc"

          if [ ! -d "$OHMYZSH" ]; then
            echo "Instalando Oh My Zsh..."

            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

            sed -i 's/ZSH_THEME=".*"/ZSH_THEME="jonathan"/' "$ZSHRC"
            sed -i '/^source \$ZSH\/oh-my-zsh.sh/i ZSH_DISABLE_COMPFIX=true' "$ZSHRC"
          fi

          # --- Garantir que o PATH do Nix não seja quebrado ---
          if ! grep -q "NIX_PROFILES" "$ZSHRC"; then
            cat << 'EOF' >> "$ZSHRC"

        # --- Nix environment ---
        if [ -e /etc/profile.d/nix.sh ]; then
          . /etc/profile.d/nix.sh
        fi
        # --- end nix ---
        EOF
          fi

          # --- Validação do GnuCOBOL ---
          echo "Validando GnuCOBOL..."
          if command -v cobc >/dev/null 2>&1; then
            cobc -V
            echo "✅ GnuCOBOL disponível no zsh."
          else
            echo "❌ cobc NÃO encontrado no PATH"
            echo "PATH atual:"
            echo "$PATH"
            exit 1
          fi
        '';


        /**
        bun-setup = ''
          echo "Instalando Bun..."
          if ! command -v bun &> /dev/null; then
            curl -fsSL https://bun.sh/install | bash
          fi

          export BUN_INSTALL="$HOME/.bun"
          export PATH="$BUN_INSTALL/bin:$PATH"

          BUN_EXPORTS='
            export BUN_INSTALL="$HOME/.bun"
            export PATH="$BUN_INSTALL/bin:$PATH"
          '

          if ! grep -q "BUN_INSTALL" "$ZSHRC"; then
            echo "Adicionando Bun ao .zshrc..."
            echo "$BUN_EXPORTS" >> "$ZSHRC"
          fi
        '';

        angular-setup = ''
          echo "Instalando Angular CLI..."
          if ! command -v ng &> /dev/null; then
            bun add -g @angular/cli
          fi
        ''; 
        **/
      };
      onStart = { };
    };
  };
}
