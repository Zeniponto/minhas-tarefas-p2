# Minhas Tarefas

Aplicativo mobile da P2 de Programação Mobile. Permite cadastrar uma conta, fazer login e gerenciar tarefas pessoais. Usa Firebase Authentication, Firebase Realtime Database e SharedPreferences.

## Executar no Android

É necessário ter Flutter, Android SDK, Java e um celular Android com depuração USB ou um emulador configurado. O projeto utiliza Flutter 3.47.7, Dart 3.13.5 e Android 7.0 (API 24) ou superior.

```bash
flutter pub get
flutter devices
flutter run -d ID_DO_ANDROID
```

Substitua `ID_DO_ANDROID` pelo identificador do celular ou emulador mostrado em `flutter devices`.

Para gerar o APK:

```bash
flutter build apk --debug
```

O arquivo será criado em `build/app/outputs/flutter-apk/app-debug.apk`.

## Configuração do Firebase

Projeto: `minhas-tarefas-p2`.

Pacote Android: `br.edu.p2.tarefas_app`.

Realtime Database: `https://minhas-tarefas-p2-default-rtdb.firebaseio.com`.

O arquivo `android/app/google-services.json` contém a configuração do aplicativo Android registrado nesse projeto. O plugin Google Services está configurado nos arquivos Gradle, e os pacotes Firebase são declarados no `pubspec.yaml`.

No console Firebase:

1. Em Authentication, habilite o método **E-mail/senha**.
2. Crie um **Realtime Database**.
3. Na aba **Regras**, publique o conteúdo de `database.rules.json`.

Para usar outro projeto Firebase, registre um aplicativo com o mesmo pacote Android, substitua o `google-services.json` e atualize o endereço do banco em `lib/services/firebase_service.dart`. Atualize também o ID em `.firebaserc` e publique as regras no novo banco.

Caso tenha o Firebase CLI instalado, as regras também podem ser publicadas com:

```bash
firebase login
firebase deploy --only database --project minhas-tarefas-p2
```

## Funcionalidades

- Cadastro com nome, e-mail e senha; login e logout pelo Firebase Authentication.
- Sessão mantida pelo Firebase ao fechar e abrir o aplicativo.
- Início com nome do usuário e quantidade de tarefas cadastradas, pendentes e concluídas.
- Drawer com Início, Minhas tarefas, Configurações, Sobre o aplicativo e Sair.
- Tarefas com título, descrição, vencimento, prioridade e situação.
- ListView com os dados das tarefas e ícones para indicar a prioridade.
- Consulta dos detalhes, edição, exclusão com confirmação e alteração da situação.
- Atualização em tempo real com `onValue` do Realtime Database.
- Temas claro e escuro, aplicados em todas as telas e salvos no SharedPreferences.

As tarefas ficam em `tarefas/UID/ID_DA_TAREFA`. Os serviços utilizam o UID do usuário autenticado, e as regras do banco impedem o acesso às tarefas de outras contas. O nome do usuário é salvo no perfil do Firebase Authentication. Senhas e sessão não são armazenadas no SharedPreferences; ele guarda somente a preferência `tema_escuro`.

## Organização

```text
lib/
├── main.dart
├── models/
│   ├── usuario.dart
│   └── tarefa.dart
├── screens/
│   ├── login_screen.dart
│   ├── cadastro_usuario_screen.dart
│   ├── home_screen.dart
│   ├── tarefas_screen.dart
│   ├── cadastro_tarefa_screen.dart
│   ├── detalhes_tarefa_screen.dart
│   ├── configuracoes_screen.dart
│   └── sobre_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   └── preferences_service.dart
├── widgets/
│   ├── drawer_menu.dart
│   ├── campo_senha.dart
│   ├── tela_autenticacao.dart
│   ├── tarefa_card.dart
│   └── mensagem.dart
└── themes/
    └── app_theme.dart
```

Os models representam os dados. Os serviços concentram autenticação, acesso ao banco e preferências. As telas utilizam esses serviços, e o tema fica em um arquivo separado.

## Verificação

```bash
flutter analyze
flutter test
```

Os oito testes verificam modelos, preferência de tema, validação e o fluxo de interface. O teste de integração no Android também percorreu cadastro, login, CRUD, navegação e tema usando o Firebase real. Os serviços em memória utilizados pelos testes de widgets estão restritos à pasta `test/`; o aplicativo utiliza o Firebase.

As dez capturas de tela ficam em `screenshots/` e foram obtidas no Android 15 de um OPPO A5 Pro 5G, utilizando uma conta temporária de teste. A reabertura do aplicativo também foi conferida no aparelho, preservando a sessão e o tema escuro.

## Publicar no GitHub

No GitHub, crie um repositório **público** chamado `minhas-tarefas-p2`. Deixe desmarcadas as opções para criar README, licença e `.gitignore`, pois o projeto já possui os arquivos necessários.

O repositório local está na branch `main`, com commits separados por etapa do desenvolvimento. Para publicar esse histórico, execute no terminal do VS Code:

```bash
git remote add origin https://github.com/SEU_USUARIO/minhas-tarefas-p2.git
git push -u origin main
```

Substitua `SEU_USUARIO` pelo seu usuário do GitHub. A autenticação poderá ser solicitada no navegador durante o envio.

O `.gitignore` exclui ferramentas locais, caches e arquivos de compilação. O código, a configuração cliente do Firebase, as regras, o README e as capturas de tela devem aparecer no repositório. Depois do envio, abra a página do repositório e confira esses arquivos antes de entregar o link.

## Documentação consultada

- [Firebase com Flutter](https://firebase.google.com/docs/flutter/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth/flutter/start)
- [Realtime Database e listeners](https://firebase.google.com/docs/database/flutter/read-and-write)
- [Regras de acesso por usuário](https://firebase.google.com/docs/database/security/rules-conditions)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
