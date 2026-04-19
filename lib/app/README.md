# lib/app/

Camada de configuração do aplicativo. É o ponto de montagem entre o entrypoint (`main.dart`) e as features.

## Objetivo

Conectar tema, navegação e widget raiz sem conter lógica de negócio.

## Arquivos

| Arquivo | Responsabilidade |
|---|---|
| `app.dart` | Widget raiz (`RetroRelayApp`). Monta o `MaterialApp` com tema e rotas. |
| `routes.dart` | Mapa de rotas nomeadas e `onGenerateRoute` para rotas com argumentos. |
| `theme.dart` | `ThemeData` global. Única fonte de cores, tipografia e formas. |

## Boas práticas

- **Nunca coloque lógica de negócio aqui.** Se o app precisar reagir a estado (ex: tema dinâmico), use `ref.watch` em `app.dart` — mas mantenha o mínimo possível.
- **Rotas sempre pelo `AppRoutes`** — nunca use strings literais de rota em outros arquivos.
- Para navegar com argumento: `Navigator.pushNamed(context, AppRoutes.novoConsole, arguments: index)`.

## O que NÃO deve ficar aqui

- Providers ou Notifiers
- Chamadas HTTP
- Lógica de autenticação ou permissões
- Widgets de feature específica
