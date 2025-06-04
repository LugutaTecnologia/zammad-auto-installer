# zammad-auto-installer
Script automatizado para instalação completa do Zammad (helpdesk open source) com Nginx, Certbot e Elasticsearch. Compatível com Ubuntu 22.04.

# Zammad Auto Installer

Script automatizado para instalação completa do [Zammad](https://zammad.org/) — sistema de helpdesk open source — com **Nginx**, **Certbot (Let's Encrypt)**, e **Elasticsearch**, em servidores Ubuntu.

> ⚠️ **Compatível e homologado exclusivamente com Ubuntu 22.04 LTS.**  
> Não testado em versões anteriores ou posteriores.

---

## 🚀 O que este script faz

- Instala e configura o Zammad
- Instala e ativa o Elasticsearch 7.x
- Configura o Nginx para servir na raiz do domínio (sem porta)
- Gera e aplica certificado SSL gratuito e auto-renovável (Let's Encrypt)
- Integra o Zammad com Elasticsearch
- Configura timezone e idioma (Brasil - pt_BR.UTF-8)

---

## ✅ Requisitos

- VPS com Ubuntu **22.04 LTS**
- Domínio válido e apontado para o IP da VPS
- Acesso root (ou `sudo`) ao servidor

---

## 📦 Como usar

Execute o script direto do GitHub com:

```bash
bash <(curl -s https://raw.githubusercontent.com/LugutaTecnologia/zammad-auto-installer/main/install_zammad_final.sh)
```

Você será solicitado a informar:

- Seu domínio (ex: `zammad.seudominio.com.br`)
- Seu e-mail (para o Certbot emitir o certificado SSL)
- Uma senha de sua escolha (usada internamente no Zammad para o Elasticsearch)

---

## 🛠️ Após a instalação

Acesse no navegador:

```
https://zammad.seudominio.com.br
```

E finalize a configuração do seu Zammad.

---

## 📝 Licença

Este projeto está licenciado sob a [MIT License](LICENSE), permitindo uso pessoal e comercial com liberdade de modificação.

---

## 🙌 Créditos

Desenvolvido e mantido por [LugutaTecnologia](https://github.com/LugutaTecnologia)

---

