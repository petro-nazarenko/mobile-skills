# Claude Code Plugin — Publication Template

Готовый шаблон для создания и публикации плагина. На основе реального проекта `react-native-best-practices`.

---

## Структура репо

```
my-plugin/
├── .claude-plugin/
│   ├── plugin.json          ← манифест плагина
│   └── marketplace.json     ← каталог маркетплейса
├── skills/
│   └── my-skill/
│       ├── SKILL.md         ← инструкция для Claude
│       └── references/      ← справочные файлы
│           ├── topic-1.md
│           └── topic-2.md
├── docs/
│   ├── index.html           ← публичный сайт (GitHub Pages)
│   └── privacy.html         ← privacy policy
└── tests/
    ├── evals.json
    └── run_tests.sh
```

---

## 1. plugin.json

```json
{
  "name": "my-plugin",
  "description": "Одна строка — что делает плагин.",
  "version": "1.0.0",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "homepage": "https://your-github.github.io/my-plugin",
  "repository": "https://github.com/your-github/my-plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2", "keyword3"]
}
```

---

## 2. marketplace.json

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "metadata": {
    "description": "Описание маркетплейса.",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./",
      "description": "Одна строка — что делает плагин.",
      "version": "1.0.0",
      "author": {
        "name": "Your Name",
        "email": "your@email.com"
      },
      "homepage": "https://your-github.github.io/my-plugin",
      "repository": "https://github.com/your-github/my-plugin",
      "license": "MIT",
      "keywords": ["keyword1", "keyword2"],
      "category": "your-category",
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

---

## 3. SKILL.md

```markdown
---
name: my-skill
description: >
  Когда использовать этот skill. Перечисли триггеры:
  конкретные слова, сценарии, типы задач.
  Claude читает это чтобы решить — применять skill или нет.
---

# My Skill

## Quick Decision Tree

1. **Проблема A?** → Читай references/topic-1.md
2. **Проблема B?** → Читай references/topic-2.md

## Reference Files

- Topic 1 → references/topic-1.md
- Topic 2 → references/topic-2.md

## Workflow

### Step 1 — Определи проблему
Разбери запрос → выбери нужный reference файл → прочитай его.

### Step 2 — Аудит (если есть кодовая база)
```bash
# команды для анализа проекта
```

### Step 3 — Ответ
Диагноз → конкретный код → до/после → почему важно.
```

---

## 4. Reference файл

```markdown
# Topic Name

## Когда использовать

| Условие | Решение |
|---------|---------|
| Случай A | Действие X |
| Случай B | Действие Y |

## Основной паттерн

```code
// конкретный рабочий пример
```

## Частые ошибки

```code
// BAD
...

// GOOD
...
```
```

---

## 5. Чеклист публикации

```
[ ] Создать репо на GitHub
[ ] Добавить .claude-plugin/plugin.json
[ ] Добавить .claude-plugin/marketplace.json  (source: "./")
[ ] Добавить skills/my-skill/SKILL.md
[ ] Добавить reference файлы
[ ] Создать docs/index.html  (GitHub Pages)
[ ] Создать docs/privacy.html
[ ] Включить GitHub Pages: Settings → Pages → main → /docs
[ ] gh repo edit --description "..." --homepage "https://..."
[ ] Добавить топики репо: claude-code, claude-plugin, [твоя тема]
[ ] Подать на claudemarketplaces.com (автоматически через daily scan)
[ ] Подать на официальный: claude.ai/settings/plugins/submit
```

---

## 6. Установка для пользователей

```
/plugin marketplace add your-github/my-plugin
/plugin install my-plugin@my-marketplace
/my-skill [вопрос или описание проблемы]
```

---

## 7. Supported platforms (для формы сабмита)

```
[x] CLI
[x] Desktop — macOS
[x] Desktop — Windows
[x] Web (claude.ai/code)
[x] VS Code
[x] JetBrains
```

---

## 8. Советы

**SKILL.md description** — самое важное поле. Claude читает его чтобы решить когда применять skill. Перечисляй конкретные триггерные слова и сценарии.

**Reference файлы** — конкретика, не теория. Таблицы решений, готовый код, паттерны до/после.

**source: "./"** — обязательно с `./`. Без слеша не работает.

**Один маркетплейс — много плагинов.** Добавляй новые плагины в тот же репо если тема одна.
