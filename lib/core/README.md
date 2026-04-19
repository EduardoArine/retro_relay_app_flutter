# lib/core/

Infraestrutura compartilhada por todas as features. Não pertence a nenhuma feature específica.

## Objetivo

Prover os blocos de construção que todas as features consomem: cliente HTTP, constantes, utilitários.

## Subpastas

### `constants/`
Valores fixos globais do app. Apenas `const` — sem instâncias, sem lógica.

- `app_constants.dart` — IP padrão, endpoints, chaves de SharedPreferences, CDN base URL.

### `network/`
Infraestrutura de rede.

- `api_client.dart` — Instância `Dio` configurada com timeouts e interceptor de log.
- `relay_api_service.dart` — As 3 chamadas HTTP ao ESP32 (`toggleCanal`, `setModo`, `testarConexao`).
- `network_exception.dart` — Wrapper público de erros de rede. Evita que `DioException` vaze para as features.

### `utils/`
Funções utilitárias sem estado. Ex: formatadores, helpers de arquivo.
*(vazio nesta fase — adicione conforme necessidade)*

## Boas práticas

- Nenhum arquivo de `core/` deve importar arquivos de `features/`.
- `relay_api_service.dart` recebe o IP como parâmetro — não armazena estado.
- Erros de rede sempre devem ser do tipo `NetworkException` ao sair de `core/network/`.

## O que NÃO deve ficar aqui

- Models de domínio (ficam em cada `feature/models/`)
- Providers específicos de feature
- Lógica de negócio
- Widgets
