# SOBRAMID-BA Conecta

Aplicativo estático com área do associado e painel administrativo separado.

## Rotas

- `/` ou `/associado`: área do associado
- `/admin`: painel administrativo
- `/primeiro-acesso`: destino inicial dos convites do Supabase Auth

## Deploy na Vercel

Configure as variáveis de ambiente no projeto da Vercel:

```txt
SUPABASE_URL=https://SEU_PROJETO.supabase.co
SUPABASE_SERVICE_ROLE_KEY=chave_service_role_somente_no_servidor
SUPABASE_INVITE_REDIRECT=https://SEU_DOMINIO/primeiro-acesso
```

Nunca exponha `SUPABASE_SERVICE_ROLE_KEY` no HTML, JavaScript público ou GitHub.

## Convites de acesso

O painel ADM chama `POST /api/invite`, que dispara:

```js
supabase.auth.admin.inviteUserByEmail(email, { redirectTo, data })
```

O texto real do e-mail pode ser personalizado em:

Supabase Dashboard -> Authentication -> Emails -> Invite user.

Para e-mails totalmente personalizados por associado, use `generateLink` no servidor e envie o e-mail por um provedor como Resend, SendGrid ou SMTP próprio.

## Próximos passos técnicos

- Criar tabelas no Supabase para associados, cobranças, certificados, eventos e comunicados.
- Trocar os dados em memória do `admin.html` por chamadas autenticadas ao Supabase.
- Proteger `/admin` com login real e regra de perfil administrativo.
- Ativar domínio oficial na Vercel.
