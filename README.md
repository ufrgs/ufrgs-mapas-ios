# UFRGS Mapas (iOS)

Aplicativo de mapas com os principais prédios da UFRGS.

## Começando

Primeiramente, clone o repositório.

### 1 - Pré-requisitos

Para gerenciamento de bibliotecas, foi utilizado o [Carthage](https://github.com/Carthage/Carthage).

Caso o Carthage não esteja instalado, use o seguinte comando:

```
brew install carthage
```

### 2 - Instalando as dependências

Execute:

```
carthage update --platform iOS --no-use-binaries
```

## Bibliotecas utilizadas

* `SwiftOverlays`
* https://github.com/peterprokop/SwiftOverlays
* Mostrar popups de carregamento

* `Realm`
* https://github.com/realm/realm-cocoa
* Armazenamento local dos dados dos prédios

## Em caso de dúvidas

* Augusto Boranga - aboranga@inf.ufrgs.br
* Lucas Flores - lsflores@inf.ufrgs.br
