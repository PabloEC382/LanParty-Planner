#!/bin/bash
# Script para copiar arquivos do providers para as novas features
# Mantém a estrutura de Clean Architecture

# Events
cp -r lib/features/providers/domain/entities/event.dart lib/features/events/domain/entities/
cp -r lib/features/providers/domain/repositories/event_repository.dart lib/features/events/domain/repositories/
cp -r lib/features/providers/infrastructure/dtos/event_dto.dart lib/features/events/infrastructure/dtos/
cp -r lib/features/providers/infrastructure/local/events_local_dao_shared_prefs.dart lib/features/events/infrastructure/local/
cp -r lib/features/providers/infrastructure/mappers/event_mapper.dart lib/features/events/infrastructure/mappers/
cp -r lib/features/providers/infrastructure/repositories/events_repository_impl.dart lib/features/events/infrastructure/repositories/
cp -r lib/features/providers/presentation/dialogs/event_form_dialog.dart lib/features/events/presentation/dialogs/
cp -r lib/features/providers/presentation/dialogs/event_actions_dialog.dart lib/features/events/presentation/dialogs/
cp -r lib/features/providers/presentation/screens/event_detail_screen.dart lib/features/events/presentation/pages/
cp -r lib/features/screens/events_list_screen.dart lib/features/events/presentation/pages/

# Games
cp -r lib/features/providers/domain/entities/game.dart lib/features/games/domain/entities/
cp -r lib/features/providers/domain/repositories/game_repository.dart lib/features/games/domain/repositories/
cp -r lib/features/providers/infrastructure/dtos/game_dto.dart lib/features/games/infrastructure/dtos/
cp -r lib/features/providers/infrastructure/local/games_local_dao_shared_prefs.dart lib/features/games/infrastructure/local/
cp -r lib/features/providers/infrastructure/mappers/game_mapper.dart lib/features/games/infrastructure/mappers/
cp -r lib/features/providers/infrastructure/repositories/games_repository_impl.dart lib/features/games/infrastructure/repositories/
cp -r lib/features/providers/presentation/dialogs/game_form_dialog.dart lib/features/games/presentation/dialogs/
cp -r lib/features/providers/presentation/dialogs/game_actions_dialog.dart lib/features/games/presentation/dialogs/
cp -r lib/features/providers/presentation/screens/game_detail_screen.dart lib/features/games/presentation/pages/
cp -r lib/features/screens/games_list_screen.dart lib/features/games/presentation/pages/

# Venues
cp -r lib/features/providers/domain/entities/venue.dart lib/features/venues/domain/entities/
cp -r lib/features/providers/domain/repositories/venue_repository.dart lib/features/venues/domain/repositories/
cp -r lib/features/providers/infrastructure/dtos/venue_dto.dart lib/features/venues/infrastructure/dtos/
cp -r lib/features/providers/infrastructure/local/venues_local_dao_shared_prefs.dart lib/features/venues/infrastructure/local/
cp -r lib/features/providers/infrastructure/mappers/venue_mapper.dart lib/features/venues/infrastructure/mappers/
cp -r lib/features/providers/infrastructure/repositories/venues_repository_impl.dart lib/features/venues/infrastructure/repositories/
cp -r lib/features/providers/presentation/dialogs/venue_form_dialog.dart lib/features/venues/presentation/dialogs/
cp -r lib/features/providers/presentation/dialogs/venue_actions_dialog.dart lib/features/venues/presentation/dialogs/
cp -r lib/features/providers/presentation/screens/venue_detail_screen.dart lib/features/venues/presentation/pages/
cp -r lib/features/screens/venues_list_screen.dart lib/features/venues/presentation/pages/

# Participants
cp -r lib/features/providers/domain/entities/participant.dart lib/features/participants/domain/entities/
cp -r lib/features/providers/domain/repositories/participant_repository.dart lib/features/participants/domain/repositories/
cp -r lib/features/providers/infrastructure/dtos/participant_dto.dart lib/features/participants/infrastructure/dtos/
cp -r lib/features/providers/infrastructure/local/participants_local_dao_shared_prefs.dart lib/features/participants/infrastructure/local/
cp -r lib/features/providers/infrastructure/mappers/participant_mapper.dart lib/features/participants/infrastructure/mappers/
cp -r lib/features/providers/infrastructure/repositories/participants_repository_impl.dart lib/features/participants/infrastructure/repositories/
cp -r lib/features/providers/presentation/dialogs/participant_form_dialog.dart lib/features/participants/presentation/dialogs/
cp -r lib/features/providers/presentation/dialogs/participant_actions_dialog.dart lib/features/participants/presentation/dialogs/
cp -r lib/features/providers/presentation/screens/participant_detail_screen.dart lib/features/participants/presentation/pages/
cp -r lib/features/screens/participants_list_screen.dart lib/features/participants/presentation/pages/

# Tournaments
cp -r lib/features/providers/domain/entities/tournament.dart lib/features/tournaments/domain/entities/
cp -r lib/features/providers/domain/repositories/tournament_repository.dart lib/features/tournaments/domain/repositories/
cp -r lib/features/providers/infrastructure/dtos/tournament_dto.dart lib/features/tournaments/infrastructure/dtos/
cp -r lib/features/providers/infrastructure/local/tournaments_local_dao_shared_prefs.dart lib/features/tournaments/infrastructure/local/
cp -r lib/features/providers/infrastructure/mappers/tournament_mapper.dart lib/features/tournaments/infrastructure/mappers/
cp -r lib/features/providers/infrastructure/repositories/tournaments_repository_impl.dart lib/features/tournaments/infrastructure/repositories/
cp -r lib/features/providers/presentation/dialogs/tournament_form_dialog.dart lib/features/tournaments/presentation/dialogs/
cp -r lib/features/providers/presentation/dialogs/tournament_actions_dialog.dart lib/features/tournaments/presentation/dialogs/
cp -r lib/features/providers/presentation/screens/tournament_detail_screen.dart lib/features/tournaments/presentation/pages/
cp -r lib/features/screens/tournaments_list_screen.dart lib/features/tournaments/presentation/pages/

# Home
cp -r lib/features/home/home_page.dart lib/features/home/presentation/pages/
cp -r lib/features/home/profile_page.dart lib/features/home/presentation/pages/
cp -r lib/features/home/tutorial_screen.dart lib/features/home/presentation/pages/
cp -r lib/features/home/upcoming_events_screen.dart lib/features/home/presentation/pages/
cp -r lib/features/home/onboarding_tooltip.dart lib/features/home/presentation/widgets/

echo "✅ Arquivos copiados com sucesso!"
