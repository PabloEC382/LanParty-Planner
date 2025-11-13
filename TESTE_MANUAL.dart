// Teste Manual do Fluxo Completo

/*
INSTRUÇÕES DE TESTE MANUAL
==========================

Para validar que o fluxo está 100% funcional, siga estes passos:

### 1. TESTE: Adicionar um Evento
1. Abra a tela de Eventos (events_list_screen.dart)
2. Clique no FAB (botão flutuante com +)
3. Dialog deve abrir com campos:
   - Nome do Evento *
   - Data do Evento * (YYYY-MM-DD)
4. Preencha:
   - Nome: "LAN Party 2024"
   - Data: "2024-12-01"
5. Clique em "Adicionar"
6. Validação:
   - ✅ Dialog fecha
   - ✅ SnackBar mostra: "Evento adicionado com sucesso!"
   - ✅ Nova evento aparece na lista com nome "LAN Party 2024"
7. Feche o app completamente
8. Reabra o app
9. Validação:
   - ✅ Evento ainda está na lista (persistência funcionando!)

### 2. TESTE: Adicionar um Jogo
1. Abra a tela de Jogos (games_list_screen.dart)
2. Clique no FAB
3. Dialog deve abrir com campos:
   - Título *
   - Gênero *
   - Descrição
   - Mín./Máx. Jogadores
   - URL da Imagem
4. Preencha:
   - Título: "Counter-Strike 2"
   - Gênero: "FPS"
   - Mín: 2, Máx: 5
   - Descrição: "Jogo competitivo"
5. Clique em "Adicionar"
6. Validação:
   - ✅ Jogo aparece na lista
   - ✅ Mostra: "Counter-Strike 2" com gênero "FPS"
   - ✅ Intervalo de jogadores: "2-5 jogadores"

### 3. TESTE: Adicionar um Participante
1. Abra a tela de Participantes (participants_list_screen.dart)
2. Clique no FAB
3. Dialog deve abrir com campos:
   - Nome *
   - Email *
   - Nickname *
   - Nível de Habilidade (1-10)
   - URL do Avatar
   - ☐ Premium
4. Preencha:
   - Nome: "João Silva"
   - Email: "joao@example.com"
   - Nickname: "JoãoGamer"
   - Nível: 7
   - Premium: ON
5. Clique em "Adicionar"
6. Validação:
   - ✅ Participante aparece na lista
   - ✅ Mostra nickname e nível

### 4. TESTE: Adicionar um Torneio
1. Abra a tela de Torneios (tournaments_list_screen.dart)
2. Clique no FAB
3. Dialog deve abrir
4. Preencha:
   - Nome: "Campeonato FPS"
   - ID do Jogo: "cs2" (ou qualquer ID)
   - Formato: "Eliminação Simples"
   - Status: "Inscrição"
   - Máx. Participantes: 16
   - Prêmio: 1000
   - Data: "2024-12-15"
5. Clique em "Adicionar"
6. Validação:
   - ✅ Torneio aparece na lista

### 5. TESTE: Adicionar um Local (Venue)
1. Abra a tela de Locais (venues_list_screen.dart)
2. Clique no FAB
3. Dialog deve abrir
4. Preencha:
   - Nome: "LAN House do Centro"
   - Cidade: "São Paulo"
   - Capacidade: 50
   - Preço/Hora: 50.00
5. Clique em "Adicionar"
6. Validação:
   - ✅ Local aparece na lista
   - ✅ Mostra: "LAN House do Centro" com "São Paulo"

### 6. TESTE: Validação de Campos Obrigatórios
1. Abra qualquer dialog
2. Clique em "Adicionar" SEM preencher campos obrigatórios
3. Validação:
   - ✅ SnackBar mostra: "Preencha todos os campos obrigatórios"
   - ✅ Dialog NÃO fecha
   - ✅ Pode continuar preenchendo

### 7. TESTE: Validação de Tipos
1. Abra dialog de Game
2. Preencha "Mín. Jogadores" com "abc"
3. Preencha "Máx. Jogadores" com "2"
4. Clique "Adicionar"
5. Validação:
   - ✅ SnackBar mostra: "Mín. de jogadores não pode ser maior que máx."
   - ✅ Dialog não fecha

### 8. TESTE: Persistência
1. Adicione 5 itens em uma tela (ex: Eventos)
2. Feche o app (Ctrl+C no terminal ou feche a emulador)
3. Aguarde 3-5 segundos
4. Reabra o app
5. Abra a mesma tela
6. Validação:
   - ✅ Todos os 5 itens continuam na lista!
   - ✅ SharedPreferences está funcionando

### 9. TESTE: Pull-to-Refresh
1. Abra qualquer tela
2. Puxe para baixo (pull-to-refresh)
3. Validação:
   - ✅ Loading indicator aparece
   - ✅ Lista recarrega

### 10. TESTE: Erro ao Converter Tipo
1. Abra dialog de Participante
2. Preencha "Nível de Habilidade" com "0"
3. Clique "Adicionar"
4. Validação:
   - ✅ SnackBar mostra: "Nível de habilidade deve estar entre 1 e 10"
   - ✅ Dialog não fecha

CHECKLIST DE VALIDAÇÃO
======================

Eventos:
  [ ] Dialog abre ao clicar FAB
  [ ] Evento é adicionado à lista
  [ ] SnackBar mostra sucesso
  [ ] Evento persiste após fechar app
  [ ] Campo "Nome" é obrigatório
  [ ] Campo "Data" é obrigatório

Games:
  [ ] Dialog abre ao clicar FAB
  [ ] Jogo é adicionado à lista
  [ ] Mostra gênero e intervalo de jogadores
  [ ] Campo "Título" é obrigatório
  [ ] Campo "Gênero" é obrigatório
  [ ] Valida mín/máx de jogadores

Participants:
  [ ] Dialog abre ao clicar FAB
  [ ] Participante é adicionado à lista
  [ ] Checkbox "Premium" funciona
  [ ] Campo "Nome" é obrigatório
  [ ] Campo "Email" é obrigatório
  [ ] Campo "Nickname" é obrigatório
  [ ] Valida nível entre 1-10

Tournaments:
  [ ] Dialog abre ao clicar FAB
  [ ] Torneio é adicionado à lista
  [ ] Dropdowns de Formato e Status funcionam
  [ ] Campo "Nome" é obrigatório
  [ ] Campo "ID do Jogo" é obrigatório

Venues:
  [ ] Dialog abre ao clicar FAB
  [ ] Local é adicionado à lista
  [ ] Mostra cidade e capacidade
  [ ] Campo "Nome" é obrigatório
  [ ] Campo "Cidade" é obrigatório
  [ ] Checkbox "Verificado" funciona

GERAL:
  [ ] FABs funcionam em todas as telas
  [ ] SnackBars aparecem corretamente
  [ ] Pull-to-refresh funciona
  [ ] Loading indicators aparecem
  [ ] Dados persistem após fechar app
  [ ] Sem errors no console

*/
