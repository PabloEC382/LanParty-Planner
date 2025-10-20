**PRD --- Gamer Event Platform: Onboarding, Consentimento e Gestão de
Eventos**

**Objetivo:** Documento de Requisitos de Produto para o
aplicativo **Gamer Event Platform**, focado em organização de
mini-eventos gamers com onboarding, consentimento LGPD e identidade
visual consistente.

**0) Metadados do Projeto**

- **Nome do Produto/Projeto:** Gamer Event Platform

- **Responsável:** Pablo Emanuel Cechim de Lima

- **Curso/Disciplina:** Desenvolvimento de Aplicações (Flutter)

- **Versão do PRD:** v1.0

- **Data:** 2025-10-08

**1) Visão Geral**

**Resumo:** O Gamer Event Platform permite que usuários criem e
gerenciem mini-eventos gamers com checklists e horários. Na primeira
execução, o app guia o usuário por um onboarding, coleta consentimentos
de privacidade e marketing, e persiste as escolhas para futuras sessões.

**Problemas que ataca:**

- Dificuldade em organizar eventos gamers de forma rápida e estruturada.

- Falta de transparência no uso de dados (LGPD).

- Interface não intuitiva para criação de checklists e horários.

**Resultado desejado:**

- Onboarding claro e engajante.

- Consentimento explícito e revisável.

- Interface fluida para CRUD de eventos.

**2) Personas & Cenários de Primeiro Acesso**

- **Persona principal:** Organizador de eventos gamers (LAN parties,
  torneios), busca praticidade e controle.

- **Cenário (happy path):**

  - Abrir app → Splash (verifica onboarding) → Onboarding (3 telas) →
    Marketing Consent → Leitura de políticas → Aceite → Home → Gerenciar
    Eventos.

- **Cenários alternativos:**

  - Onboarding já feito → Splash → Home.

  - Revogar consentimento → Retorna ao onboarding.

**3) Identidade do Tema (Design)**

**3.1 Paleta e Direção Visual**

- Primária: purple #7C3AED

- Secundária: cyan #06B6D4

- Superfície: slate #0F172A

- Texto: Colors.white

- Direção: Tema escuro, alto contraste, useMaterial3 implícito.

**3.2 Tipografia**

- Títulos: headlineMedium (28px, bold)

- Corpo: bodyMedium (16px)

- Fonte: Roboto

**3.3 Iconografia & Ilustrações**

- Ícones Material Icons

- Logo: PNGs/logoIASemfundo.png

- Estilo: Flat, minimalista, alto contraste.

**3.4 Prompts:**

- **Ícone do app/Logo:** "Gere uma logo para uma aplicação em flutter,
  com formato 1024x1024. Como é uma aplicação para um aplicativo que
  organiza mini-eventos gamers, coloque um controle, aos moldes do XBOX,
  com um calendário atrás. Use paletas purple, cyan e slate,
  hexadecimais respectivamente, \#7C3AED, \#06B6D4 e \#0F172A. Faça algo
  moderno, minimalista, mas com degradê"

**4) Jornada de Primeira Execução (Fluxo Base)**

**4.1 Splash Screen**

- Exibe logo e título.

- Verifica onboarding_done e redireciona para Home ou Onboarding.

**4.2 Onboarding (3 telas + 2 extras)**

1.  Boas-vindas + botão Avançar.

2.  Explicação do app.

3.  Finalização.

4.  Marketing Consent (opcional).

5.  Resumo de consentimento (Política + Termos).

**4.3 Leitura de Políticas**

- Tela de markdown com scroll obrigatório.

- Botão \"Concordo\" só habilita ao final.

**4.4 Home & Revogação**

- Botão para gerenciar eventos.

- Botão para revogar consentimento (com confirmação).

**5) Requisitos Funcionais (RF)**

- **RF-1:** Splash redireciona com base em onboarding_done.

- **RF-2:** Onboarding com navegação Avançar/Voltar.

- **RF-3:** Leitura de políticas com progresso de scroll.

- **RF-4:** Aceite só após ler ambos os documentos.

- **RF-5:** CRUD completo de eventos (nome, horários, checklist,
  pessoas).

- **RF-6:** Persistência local com SharedPreferences.

- **RF-7:** Revogação de consentimento com confirmação e retorno ao
  onboarding.

- **RF-8:** Tela de histórico de consentimento.

**6) Requisitos Não Funcionais (RNF)**

- **A11Y:** Contraste AA, alvos ≥ 48dp, Semantics onde aplicável.

- **LGPD:** Transparência, aceite explícito, revogação simples.

- **Arquitetura:** Separação entre UI e lógica (ex: StorageService).

- **Performance:** Animações suaves, evitar rebuilds desnecessários.

- **Testabilidade:** Serviços mockáveis (ex: SharedPreferences).

**7) Dados & Persistência (chaves)**

- onboarding_done: bool

- consent_accepted: bool

- events: List\<Event\> (JSON)

- marketing_consent: bool (opcional)

- politica_lida: bool

- termos_lidos: bool

**8) Roteamento**

- / → Splash (rota inicial)

- /onboarding → OnboardingScreen

- /home → MyHomePage

- /events → EventCrudScreen

- /consent-history → ConsentHistoryScreen

- /policy-viewer → LeituraMdPage

**9) Critérios de Aceite**

- Splash redireciona corretamente com base em onboarding_done.

- Onboarding navega entre telas e salva estado ao final.

- Leitura de políticas exige scroll completo para habilitar botão.

- Eventos são criados, editados e excluídos com persistência.

- Consentimento pode ser revogado via tela de histórico.

- UI não acessa SharedPreferences diretamente.

- Cores e fontes seguem o tema definido.

**10) Protocolo de QA (testes manuais)**

- **Primeira execução:** Onboarding completo → Aceite → Home.

- **Reabertura:** Vai direto para Home.

- **Criação de evento:** Preenche todos os campos → Salva → Lista
  atualizada.

- **Revogação:** Confirma → Retorna ao onboarding.

- **Leitura parcial:** Não habilita aceite.

- **A11Y:** Text scaling 1.3+, contraste, foco visível.

**11) Riscos & Decisões**

- **Risco:** Versionamento de políticas → Mitigação: Hash ou versão em
  chave.

- **Decisão:** Onboarding com 5 telas (3 info + 2 consentimento).

- **Decisão:** Scroll obrigatório em políticas para garantir leitura.

- **Decisão:** Tema escuro para melhor experiência em ambientes de
  jogos.

**12) Entregáveis**

1.  PRD completo.

2.  Código implementado (Flutter).

3.  Assets: logo, ícones, arquivos .md.

4.  Evidências de teste (prints, vídeos).

**13) Backlog de Evolução (opcional)**

- Notificações para eventos.

- Sincronização com calendário.

- Compartilhamento de eventos.

- Backup em nuvem.

- Modo offline reforçado.

**14) Referências Internas**

- StorageService: Camada de persistência.

- LeituraMdPage: Viewer reutilizável para markdown.

- ConsentHistoryScreen: Revogação e histórico.

- EventCrudScreen: CRUD completo de eventos.

**Checklist de Conformidade (PR)**

- Splash decide rota por onboarding_done

- Onboarding com navegação contextual

- Leitura de políticas com scroll completo obrigatório

- Aceite só após ler os 2 documentos

- CRUD de eventos persistido localmente

- Revogação de consentimento funcional

- UI não acessa SharedPreferences diretamente

- A11Y: contraste, tamanho de alvo, Semantics

- Identidade visual aplicada (cores, fontes, ícones)
