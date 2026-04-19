# lib/features/

Cada feature é uma unidade isolada de funcionalidade do app. Toda a lógica de negócio, estado, dados e UI de uma funcionalidade fica dentro da sua pasta.

## Features atuais

| Feature | Descrição |
|---|---|
| `home/` | Grid de consoles com toggles de liga/desliga. |
| `cadastro/` | Lista dos 16 canais disponíveis para configuração. |
| `novo_console/` | Formulário para cadastrar/editar um console em um canal. |
| `config/` | Configurações do app: IP do ESP32, modo de operação. |
| `voice_control/` | Controle por voz para acionar canais. |

> **Nota:** A pasta `auth/` foi criada em uma sessão exploratória anterior e **não faz parte da arquitetura atual**. O app não possui fluxo de autenticação. Ela pode ser removida com segurança.

## Estrutura interna de cada feature

```
feature/
  data/         # Services e repositories (acesso a dados)
  models/       # Classes de domínio da feature (imutáveis, com copyWith)
  presentation/ # Screens e Notifiers (UI + estado)
```

## Regras de isolamento

1. Uma feature **não importa diretamente de outra feature** — exceto quando há dependência explícita e documentada (ex: `voice_control` usa `CanaisNotifier` de `home`).
2. Shared reutilizáveis vão para `shared/widgets/`, não ficam duplicados entre features.
3. `data/` não importa de `presentation/`.
4. `presentation/` pode importar de `data/` e `models/` da mesma feature.

## Boas práticas

- Um `Notifier` por tela complexa. Telas simples (só leitura) podem usar `ConsumerWidget` direto.
- Models sempre imutáveis com `copyWith`.
- Services cuidam de I/O. Repositories fazem a ponte para os Notifiers.

## O que NÃO deve ficar aqui

- Código de infraestrutura genérica (fica em `core/`)
- Widgets usados por 2+ features (ficam em `shared/widgets/`)
