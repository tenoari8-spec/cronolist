# Cronolist (dados no Supabase)

Site estático (HTML + JavaScript). Os dados ficam no **Supabase**; o site pode ficar em qualquer hospedagem
(GitHub Pages, Netlify, domínio próprio...). Basta enviar os arquivos desta pasta.

## 1. Preparar o Supabase (uma vez)
1. No painel do projeto, abra **SQL Editor → New query**.
2. Abra o arquivo `supabase.sql` deste zip, copie **tudo**, cole e toque em **Run**.
   Isso cria as tabelas, o bucket de imagens `uploads` e as regras de segurança:
   **todos leem; só o usuário administrador (ID 6988bab9-ee8e-4110-922a-7ee1953b7d02) grava, envia e apaga.**
3. Em **Authentication → Users**, confira que o usuário administrador existe, tem **e-mail e senha** e está confirmado.
   Se foi criado só por link mágico ou login social, defina uma senha (menu do usuário → enviar redefinição de senha).
4. Recomendado: em **Authentication**, desligue a criação de novas contas (opção *Allow new users to sign up*).
   Mesmo ligada, ninguém além do administrador consegue gravar, por causa das regras do passo 2.

O site já vem configurado com a URL do projeto e a chave pública (`sb_publishable_...`) dentro do `index.html`
(bloco `const SB={...}`). Essa chave pode ser pública. **Nunca** coloque a chave secreta (`service_role` / `sb_secret_...`) no site.

## 2. Publicar o site
Envie todos os arquivos para a raiz da hospedagem (`index.html`, `manifest.webmanifest`, `sw.js`, `404.html`, pasta `icons/`, `.nojekyll`).
- **GitHub Pages:** Settings → Pages → Deploy from a branch → `main` / `(root)`.
- **Netlify:** arraste a pasta, ou conecte o repositório. Nenhum comando de build é necessário.
Não precisa enviar o `supabase.sql` para a hospedagem.

## 3. Entrar como administrador
Abra `https://SEU-SITE/#admin`, informe o **e-mail e a senha** do usuário administrador e toque em **Entrar**.
Não existe botão público de login. O painel só abre para a conta do administrador; as regras do banco garantem isso.
A sessão fica salva no navegador. **Sair** (no topo do painel) encerra.

## 4. Cadastrar (painel `#admin`)
O painel é organizado em seções. Toque na seção e depois em **+ Novo**:
- **Emissoras:** lista com pesquisa e filtro por categoria (TV Aberta, TV Fechada, Streaming, Extinta, Regional, Internacional, Partido). Também cadastra países.
- **Praças:** escolha a emissora → cadastre as praças (ex.: Bom Dia Praça) → dentro de cada praça, os telejornais (ex.: Bom Dia Acre, com estado e emissora que exibe).
- **Cronologias:** cronologias de cada emissora (alimentam a porcentagem e o TOP 10).
- **Esportes:** competições, emissoras de esporte (com código E1, E2...), transmissões por ano, vinhetas e "disponível no canal".
- **Programação:** calendário (toque numa data e adicione horários com nome, faixa e disponível ✓/✕) e as faixas (nome, no ar ou não, descrição).
- **Política:** partidos, evolução dos partidos, presidente, governadores, prefeitos das capitais, prefeituras por partido e datas das eleições.
- **Trens e Metrô:** linhas, estações (com aviso sonoro), operadoras, operação das linhas, frota e efeitos sonoros.
- **Nosso Futebol:** participantes inéditos, campeões inéditos e acessos.
- **Estaduais na TV:** transmissões por ano, gênero, nível, divisão e estado (mais de uma emissora no mesmo estado aparece com as duas logos).
- **Cronopedia:** artigos da enciclopédia e registros do INPI Fictício. No artigo: título, resumo, texto, categorias, caixa de informações e imagem. Cada vez que você salva, uma versão fica no histórico.
  Escreva o texto assim: `## Título`, `### Subtítulo`, `- item`, `**negrito**`, `*itálico*`, `[[Outro artigo]]` (link para outro artigo; fica vermelho se o artigo não existir) e `[texto](https://site)`.
- **Pede Aqui:** pedidos de cronologias. A data do pedido não é obrigatória; o site registra sozinho a data em que foi adicionado.

Nos formulários, listas longas (emissoras, estados, competições) têm campo de pesquisa. A pesquisa ignora acentos.
Logos, bandeiras, escudos e sons/vinhetas (áudio ou vídeo, até 40 MB) são enviados para o Storage do Supabase (bucket `uploads`).
Tudo aparece na hora para todos os aparelhos: os dados vêm do banco, não do navegador.

## Cronopedia em endereço próprio (opcional)
O botão **Cronopedia** fica depois da logo. A Cronopedia é a mesma hospedagem: `SEU-SITE/#cronopedia`.
Se você apontar um segundo endereço que comece com `cronopedia.` (ex.: `cronopedia.seudominio.com`) para esta mesma hospedagem, ele já abre direto na Cronopedia.
Por enquanto só o administrador edita. Para liberar parceiros no futuro será preciso mudar as regras de segurança do banco (`supabase.sql`), que hoje só deixam o administrador gravar.

## 5. TOP 10 das emissoras
Ranking das emissoras com mais cronologias; em caso de empate, vence a que tem maior porcentagem de cronologias atualizadas.
Não depende de acessos e não precisa do contador do banco.

## Observação sobre o banco
Esta versão não muda as tabelas: se você já rodou o `supabase.sql`, **não precisa rodar de novo**.
Registros antigos de tipos que foram redesenhados (programação, faixas, competições, pedidos, Lançamentos) podem aparecer incompletos; recadastre-os pelo painel.

## Se algo der errado
- **"Não foi possível carregar os dados":** confira se rodou o `supabase.sql` e se o projeto não está pausado.
- **"E-mail ou senha incorretos":** confira a senha do usuário em Authentication → Users.
- **"Esta conta não tem permissão de administrador":** o login é de outro usuário; use o usuário cujo ID está nas regras.
- **"row-level security" ao salvar:** o `supabase.sql` não foi rodado, ou o ID do administrador nas regras está diferente do usuário logado.
