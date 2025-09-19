# Deploy SSIBRASIL (Windows .bat)

1) Coloque este arquivo `deploy_ssibrasil_site.bat` na **mesma pasta** onde está o `index.html` do site.
2) (Opcional) Troque a URL do Git remoto no .bat ou passe como argumento:
   - Dentro do .bat:  git@github.com:SEU_USUARIO/ssibrasil-site.git
   - Ou no terminal:  deploy_ssibrasil_site.bat https://github.com/SEU_USUARIO/ssibrasil-site.git
3) Execute o .bat (clique duplo).

**Observações**:
- Instale antes: **Git**, **Node.js** (NPM) e faça `vercel login` uma vez.
- O script faz:
  - `git init`, commit e `push` para `main` (forçado).
  - `vercel --prod --yes` para publicar.
- Se preferir só Vercel, ignore/edite a parte do Git.

