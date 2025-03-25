#!/bin/bash
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh

# KCL
## https://www.kcl-lang.io/docs/user_docs/getting-started/install
curl -fsSL https://kcl-lang.io/script/install-cli.sh | /bin/bash
## https://www.kcl-lang.io/docs/user_docs/getting-started/install#install-language-server
curl -fsSL https://kcl-lang.io/script/install-kcl-lsp.sh | /bin/bash
