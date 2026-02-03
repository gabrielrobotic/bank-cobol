{ pkgs, ... }: {
  channel = "stable-25.05";
  packages = with pkgs; [
    zsh
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
          echo "Verificando Oh My Zsh..."

          export RUNZSH=no
          export CHSH=no

          OHMYZSH="$HOME/.oh-my-zsh"
          ZSHRC="$HOME/.zshrc"

          if [ ! -d "$OHMYZSH" ]; then
            echo "Oh My Zsh não encontrado. Instalando..."

            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

            echo "Configurando tema 'jonathan'..."
            sed -i 's/ZSH_THEME=".*"/ZSH_THEME="jonathan"/' "$ZSHRC"

            echo "Inserindo ZSH_DISABLE_COMPFIX=true..."
            sed -i '/^source \$ZSH\/oh-my-zsh.sh/i ZSH_DISABLE_COMPFIX=true' "$ZSHRC"
          fi

          echo "🔧 Configurando GnuCOBOL no ambiente..."

          # Garantir HOME válido (evita warnings estranhos)
          if [ -z "$HOME" ]; then
            export HOME="/home/user"
          fi

          echo "HOME = $HOME"

          # Instalar GnuCOBOL se não existir
          if ! command -v cobc >/dev/null 2>&1; then
            echo "GnuCOBOL não encontrado. Instalando via apt-get..."

            sudo apt-get update
            sudo apt-get install -y gnucobol
          else
            echo "GnuCOBOL já instalado."
          fi

          # Garantir que o PATH esteja correto no zsh
          ZSHRC="$HOME/.zshrc"

          if ! grep -q "GnuCOBOL" "$ZSHRC"; then
            echo "Exportando PATH do GnuCOBOL no .zshrc..."

            cat << 'EOF' >> "$ZSHRC"

# >>> GnuCOBOL >>>
export PATH="/usr/bin:$PATH"
# <<< GnuCOBOL <<<
EOF
          fi

          # Validação final
          echo "Validando instalação do COBOL..."
          cobc -V

          echo "✅ GnuCOBOL configurado com sucesso."
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
