---
name: tao-security-audit
description: "Auditoria de segurança alinhada ao OWASP Top 10 com checklist para injection, XSS, autenticação, autorização, gestão de secrets e vulnerabilidades comuns. Use ao auditar segurança, revisar código de auth ou hardening de aplicação."
argument-hint: "Descreva o que auditar ou a preocupação de segurança"
---
# TAO Auditoria de Segurança (OWASP)

## Quando usar
Use para auditorias de segurança, reviews de auth, avaliação de vulnerabilidades ou antes do deploy em produção.

## Checklist OWASP Top 10

### A01 — Controle de Acesso Quebrado
- [ ] Todo endpoint verifica autorização ANTES de processar
- [ ] Default deny: acesso negado a menos que explicitamente concedido
- [ ] CORS configurado com origens específicas (não `*`)
- [ ] Directory traversal: caminhos sanitizados (sem `../`)
- [ ] Rate limiting de API implementado
- [ ] Tokens JWT/sessão com expiração razoável

### A02 — Falhas Criptográficas
- [ ] Senhas com hash bcrypt/argon2 (NÃO md5/sha1)
- [ ] HTTPS forçado em todo lugar
- [ ] Dados sensíveis criptografados em repouso
- [ ] Sem secrets no código fonte (use .env)
- [ ] Sem dados sensíveis em logs ou mensagens de erro

### A03 — Injection
- [ ] SQL: APENAS queries parametrizadas (zero concatenação)
- [ ] NoSQL: input sanitizado antes de queries
- [ ] Command injection: sem input do usuário em comandos shell
- [ ] LDAP injection: queries LDAP parametrizadas
- [ ] Template injection: input do usuário não usado em templates

### A04 — Design Inseguro
- [ ] Modelo de ameaças existe para features críticas
- [ ] Cenários de abuso de lógica de negócio considerados
- [ ] Limites de recursos previnem abuso (tamanho arquivo, qtd requests)

### A05 — Configuração de Segurança Incorreta
- [ ] Modo debug OFF em produção
- [ ] Credenciais padrão alteradas
- [ ] Mensagens de erro não revelam stack traces
- [ ] Métodos HTTP desnecessários desabilitados
- [ ] Headers de segurança configurados (CSP, X-Frame, HSTS)

### A06 — Componentes Vulneráveis
- [ ] Dependências sem CVEs conhecidos
- [ ] Dependências atualizadas (dentro do razoável)
- [ ] Lock files commitados (package-lock.json, poetry.lock, etc.)

### A07 — Falhas de Autenticação
- [ ] Política de senha forte aplicada
- [ ] Bloqueio de conta após tentativas falhas
- [ ] Multi-fator disponível para operações sensíveis
- [ ] Invalidação de sessão no logout
- [ ] Sem exposição de credenciais em URLs

### A08 — Falhas de Integridade de Dados
- [ ] Dependências vêm de fontes confiáveis
- [ ] Pipeline CI/CD tem verificações de integridade
- [ ] Serialização é segura (sem deserialização arbitrária)

### A09 — Falhas de Log e Monitoramento
- [ ] Tentativas de login falhas são logadas
- [ ] Falhas de controle de acesso são logadas
- [ ] Logs não contêm dados sensíveis
- [ ] Alertas existem para padrões suspeitos

### A10 — SSRF
- [ ] URLs fornecidas pelo usuário são validadas (allowlist)
- [ ] Serviços internos não acessíveis via requests do usuário
- [ ] Redirects de URL são validados

## Formato de Saída
```
## Auditoria de Segurança — [escopo]
**Data:** AAAA-MM-DD
**Severidade:** CRÍTICA | ALTA | MÉDIA | BAIXA

### Achados
| # | Categoria | Severidade | Achado | Remediação |
|---|-----------|------------|--------|------------|
| 1 | A03       | ALTA       | ...    | ...        |

### Resumo
- Crítica: X | Alta: X | Média: X | Baixa: X
- Veredicto: APROVADO | APROVADO CONDICIONAL | REPROVADO
```
