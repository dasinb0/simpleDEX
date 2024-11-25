# TokenA, TokenB y SimpleDEX

## Descripción
Este repositorio contiene tres contratos inteligentes desarrollados en Solidity que implementan funcionalidades avanzadas de tokens ERC20 y un intercambio descentralizado (DEX) simple:

- **TokenA** y **TokenB**: Tokens ERC20 con características como límites de transacción, pausabilidad, y capacidades de acuñación y quema.
- **SimpleDEX**: Un contrato para intercambiar `TokenA` y `TokenB` con funcionalidades de gestión de liquidez, cálculo de precios automático y protección contra ataques de reentrancy.

## Características Principales

### Tokens (TokenA y TokenB)
- **Suministro máximo:** 1,000,000 unidades.
- **Límite de transacción:** 10,000 tokens por operación.
- **Funcionalidades:**
  - Pausabilidad de las transferencias.
  - Quema de tokens.
  - Acuñación controlada por el propietario.

### SimpleDEX
- Adición y remoción de liquidez entre `TokenA` y `TokenB`.
- Swaps con cálculo automático del precio basado en las reservas.
- Protección contra ataques de reentrancy.
- **Tarifa:** 0.3% por cada intercambio.

---

## Funciones Principales

### TokenA / TokenB

| **Función**             | **Descripción**                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `mint(to, amount)`       | Acuña tokens al destinatario. Solo el propietario puede ejecutarla.                             |
| `burn(amount)`           | Quema tokens de la cuenta del remitente.                                                        |
| `pause()` / `unpause()`  | Pausa o reanuda las operaciones del token.                                                      |
| `transfer(to, amount)`   | Transfiere tokens respetando los límites de transacción y pausabilidad.                         |

---

### SimpleDEX

| **Función**             | **Descripción**                                                                                  |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `addLiquidity(a, b)`     | Agrega liquidez al DEX para `TokenA` y `TokenB`. Solo el propietario puede ejecutarla.           |
| `removeLiquidity(a, b)`  | Retira liquidez del DEX.                                                                         |
| `swapAforB(a)`           | Intercambia una cantidad `a` de `TokenA` por `TokenB`.                                          |
| `swapBforA(b)`           | Intercambia una cantidad `b` de `TokenB` por `TokenA`.                                          |
| `getPrice(token)`        | Devuelve el precio actual de un token con base en las reservas.                                 |

---

## Eventos

### TokenA / TokenB
- `TokensMinted(address to, uint256 amount, uint256 totalSupply)`
- `TokensBurned(address from, uint256 amount, uint256 totalSupply)`
- `MintingPaused(address by)`
- `MintingResumed(address by)`

### SimpleDEX
- `LiquidityAdded(address provider, uint256 amountA, uint256 amountB)`
- `LiquidityRemoved(address provider, uint256 amountA, uint256 amountB)`
- `Swap(address sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut)`

---

### Licencia
Este proyecto está licenciado bajo la MIT License.
