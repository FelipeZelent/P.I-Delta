# Delta E-commerce (Flutter + Firebase)

App de e-commerce com Home, Favoritos, Carrinho (cupom), Detalhe do produto, Perfil (login, editar dados, alterar senha), Histórico de compras.

## Stack
- Flutter (Material 3, dark theme)
- Firebase Auth, Firestore

## Screens
Home · Product Detail · Favorites · Cart (cupom) · Profile · Orders

| Home | Detalhe | Carrinho |
|---|---|---|
| <img src="docs/screens/home_sem_conta.png" width="260" /> | <img src="docs/screens/produto.png" width="260" /> | <img src="docs/screens/carrinho.png" width="260" /> |

| Favoritos | Perfil |
|---|---|
| <img src="docs/screens/favoritos.png" width="260" /> | <img src="docs/screens/perfil.png" width="260" /> |

## Rodando o projeto
1. Flutter 3.32.8
2. Adicionar credenciais Firebase:
    - Android: `android/app/google-services.json`
3. `flutter pub get`
4. `flutter run`

## Estrutura do Firestore 
- `Products/{categoria}/items/{pid}` → { title, description, price, images[], sizes[] }
- `users/{uid}/favorites/{categoria_pid}` → { category, pid }
- `users/{uid}/cart/{categoria_pid_size}` → { category, pid, size, qty, addedAt }
- `orders/{orderId}` → { clientId, products[], productsPrice, couponCode, discountPercent, discountValue, totalPrice, status, createdAt }
- `coupons/{CODE}` → { percent: 10 }

## Licença
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
