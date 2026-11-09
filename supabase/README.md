# Preparação para sincronização segura — Supabase

Esta branch prepara a infraestrutura; **não habilita sincronização por si só**.

1. Criar projeto em https://supabase.com/dashboard e ativar autenticação por e-mail.
2. Executar `supabase/schema.sql` no SQL Editor.
3. Obter **Project URL** e **Publishable key** em Project Settings / API. A chave publicável pode estar no frontend **somente com RLS ativo**. Nunca inserir service_role/secret key no GitHub ou no HTML.
4. Antes de migrar, em **cada computador** exportar backup JSON em Configurações. Os backups podem divergir; escolher base e reconciliar lançamentos por IDs antes de importar.
5. Implementação seguinte: formulário de login, sessão Supabase, leitura/gravação autenticada, controle de revisão para evitar sobrescrita simultânea, importação assistida e armazenamento de anexos privados.
6. Testar com duas sessões em computadores diferentes, logout, RLS (outro usuário não lê dados), conflitos e recuperação de backup. Somente então liberar para produção.

**Nota de segurança:** o repositório atualmente é público. Não publicar dados pessoais, notas, comprovantes, senhas ou chaves secretas. O SQL cria um registro por usuário e políticas RLS para restringir acesso. Não há compartilhamento automático entre usuários distintos.
