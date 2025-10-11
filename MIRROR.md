# Public Mirror (зеркало репозитория)

Этот репозиторий содержит workflow **iLab Public Mirror**, который публикует «очищенную» копию кода в отдельный публичный репозиторий.

## TL;DR

- Пуш в `master` → автоматически запускает mirror и форс-пушит снимок в зеркало.
- Ручной запуск:  
  ```bash
  # если LD_PRELOAD мешает gh, можно так:
  alias ghx='env -u LD_PRELOAD gh'
  ghx workflow run .github/workflows/ilab-mirror.yml --ref master
