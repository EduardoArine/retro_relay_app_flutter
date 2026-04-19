# lib/shared/

Componentes visuais reutilizados por duas ou mais features.

## Objetivo

Evitar duplicação de widgets sem criar acoplamento entre features.

## Subpastas

### `widgets/`
Widgets stateless ou levemente stateful sem dependência de feature específica.

Exemplos planejados:
- `console_card.dart` — Card individual com imagem, nome e toggle.
- `console_grid.dart` — Grid 2 colunas de `ConsoleCard`.
- `app_bottom_nav_bar.dart` — Bottom nav com indicador de conectividade.
- `app_header.dart` — AppBar com título e botão de microfone opcional.
- `header_bar_with_back.dart` — AppBar com botão voltar.

## Boas práticas

- Widgets aqui são **agnósticos de feature** — recebem dados via parâmetros, não via `ref.watch` de providers específicos.
- Se um widget precisar de estado global, prefira receber um callback ao invés de ler um provider diretamente.
- Documente os parâmetros obrigatórios e opcionais com comentários ou `assert`.

## O que NÃO deve ficar aqui

- Screens completas (ficam em `features/*/presentation/`)
- Notifiers ou providers
- Models de domínio
- Widgets usados por apenas uma feature (ficam em `features/*/presentation/`)
