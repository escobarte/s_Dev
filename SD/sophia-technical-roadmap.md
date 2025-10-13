# SOPHIA TECHNICAL ROADMAP

## От нуля до готовой персоны

**Персонаж:** Sophia Reed (sophiaR)  
**Цель:** Создать консистентного AI-персонажа для эротического фото-контента  
**Время:** 3-5 дней  
**Платформа:** Stable Diffusion Forge

---

## PHASE 1: ПОДГОТОВКА И ВЫБОР МОДЕЛИ

### 1.1 Выбор и установка SD модели

- [ ] Выбрать реалистичную модель (рекомендуется):
  - [ ] **Realistic Vision v6.0** (лучший для MILF)
  - [ ] Deliberate v3
  - [ ] CyberRealistic v4.2
- [ ] Скачать выбранную модель (.safetensors)
- [ ] Поместить в папку `stable-diffusion-webui-forge/models/Stable-diffusion/`
- [ ] Запустить Forge
- [ ] Загрузить модель в интерфейсе (Checkpoint dropdown)
- [ ] Проверить что модель загрузилась корректно

**Время:** 30 минут  
**Результат:** Рабочая SD модель в Forge

---

## PHASE 2: ПРОМПТ ТЕСТИРОВАНИЕ

### 2.1 Создание базового промпта

- [ ] Открыть txt2img в Forge
- [ ] Скопировать базовый промпт:

```
34 year old caucasian woman, mature beauty, MILF,
curvy athletic build, fit body with natural curves,
oval face with soft features, green eyes with gold flecks,
shoulder length wavy brown hair with caramel highlights,
full natural lips, small beauty mark above upper lip right side,
fair-medium skin with warm undertone,
warm confident smile,
photorealistic, professional photography, natural lighting,
high quality, detailed
```

- [ ] Добавить negative prompt:

```
cartoon, anime, illustration, drawing, 3d render,
young, teen, child, elderly,
tattoos, piercings, multiple people,
low quality, blurry, distorted, deformed,
bad anatomy, extra limbs, fake breasts, implants,
oversaturated, heavy makeup, plastic surgery look
```

### 2.2 Настройка параметров генерации

- [ ] Установить параметры:
  - [ ] Steps: **30**
  - [ ] CFG Scale: **7**
  - [ ] Sampler: **DPM++ 2M Karras**
  - [ ] Size: **512x768** (portrait)
  - [ ] Batch count: **1**
  - [ ] Batch size: **1**

### 2.3 Первая генерация

- [ ] Нажать Generate
- [ ] Получить первое изображение
- [ ] Оценить результат:
  - [ ] Лицо выглядит как 34-летняя женщина?
  - [ ] Есть зелёные глаза?
  - [ ] Каштановые волосы с highlights?
  - [ ] Curvy athletic телосложение?
  - [ ] Beauty mark над губой?

### 2.4 Итерация и улучшение

- [ ] Сгенерировать 10-15 вариантов (разные seeds)
- [ ] Для каждого хорошего результата записать seed
- [ ] Выбрать **3-5 лучших** изображений
- [ ] Записать seeds лучших результатов
- [ ] Выбрать ОДИН лучший seed для базы

**Время:** 1-2 часа  
**Результат:** Понимание как выглядит Sophia, лучшие seeds

---

## PHASE 3: СОЗДАНИЕ ДАТАСЕТА

### 3.1 Подготовка структуры

- [ ] Создать папку проекта: `Sophia_Dataset`
- [ ] Создать подпапки:
  - [ ] `images/` - для сгенерированных фото
  - [ ] `captions/` - для текстовых описаний
  - [ ] `output/` - для LoRA

### 3.2 Генерация датасета - Углы (5 серий по 5 фото)

**Серия 1: Фронтальный вид**

- [ ] Промпт: `front view, looking at camera, centered composition`
- [ ] Сгенерировать 5 фото (варьировать seed)
- [ ] Сохранить в `images/` как `sophia_001.png` - `sophia_005.png`

**Серия 2: 3/4 вид**

- [ ] Промпт: `three quarter view, slight angle, looking at camera`
- [ ] Сгенерировать 5 фото
- [ ] Сохранить как `sophia_006.png` - `sophia_010.png`

**Серия 3: Профиль**

- [ ] Промпт: `side profile view, elegant pose`
- [ ] Сгенерировать 5 фото
- [ ] Сохранить как `sophia_011.png` - `sophia_015.png`

**Серия 4: Сверху вниз**

- [ ] Промпт: `from above, looking up at camera`
- [ ] Сгенерировать 5 фото
- [ ] Сохранить как `sophia_016.png` - `sophia_020.png`

**Серия 5: Снизу вверх**

- [ ] Промпт: `from below, looking down at camera`
- [ ] Сгенерировать 5 фото
- [ ] Сохранить как `sophia_021.png` - `sophia_025.png`

### 3.3 Генерация датасета - Вариации (5-10 фото)

**Разные выражения:**

- [ ] Neutral expression (2 фото)
- [ ] Warm smile (2 фото)
- [ ] Sultry/seductive look (2 фото)
- [ ] Playful expression (1-2 фото)
- [ ] Сохранить как `sophia_026.png` - `sophia_035.png`

### 3.4 Обработка изображений

- [ ] Открыть Forge → Extras tab
- [ ] Batch Process from Directory
- [ ] Input: `Sophia_Dataset/images/`
- [ ] Resize: **768x768** (квадрат для тренировки)
- [ ] Crop and resize (center crop)
- [ ] Process все изображения
- [ ] Проверить что все 25-35 фото одного размера

**Время:** 2-3 часа  
**Результат:** 25-35 изображений Sophia разных углов и выражений

---

## PHASE 4: ТЕГГИРОВАНИЕ ДАТАСЕТА

### 4.1 Установка WD Tagger

- [ ] В Forge → Extensions → Available
- [ ] В поиске ввести: `WD Tagger` или `wd14-tagger`
- [ ] Нажать Install напротив "Tagger for Automatic1111"
- [ ] После установки → Apply and restart UI
- [ ] Проверить появление новой вкладки "Tagger"

### 4.2 Автоматическое теггирование

- [ ] Открыть вкладку **Tagger**
- [ ] Настройки:
  - [ ] Interrogator: **WD 1.4 ViT v2**
  - [ ] Threshold: **0.35**
- [ ] Batch Process:
  - [ ] Input directory: `Sophia_Dataset/images/`
  - [ ] Output directory: `Sophia_Dataset/captions/`
  - [ ] ✅ Use filename as tag
  - [ ] ✅ Save as .txt files
- [ ] Нажать **Interrogate**
- [ ] Дождаться завершения (1-5 минут)
- [ ] Проверить что в `captions/` появились .txt файлы

### 4.3 Ручное редактирование тегов

- [ ] Открыть первый .txt файл (`sophia_001.txt`)
- [ ] **Добавить в начало:** `sophiaR, `
- [ ] **Добавить важные теги:** `34 years old, mature woman, MILF, green eyes, brown wavy hair, beauty mark above lip, curvy athletic,`
- [ ] **Удалить ненужные:** generic теги типа `photo`, `realistic` (если избыточно)
- [ ] **Пример итогового тега:**

```
sophiaR, 34 years old, mature woman, MILF, 1woman, solo, 
green eyes, brown wavy hair, beauty mark above lip, 
curvy athletic build, caucasian, front view, looking at camera,
warm smile, photorealistic
```

- [ ] Повторить для ВСЕХ 25-35 файлов
- [ ] Варьировать специфичные теги (angle, expression, clothing если есть)
- [ ] Сохранить все изменения

**Время:** 1-2 часа  
**Результат:** Все изображения имеют текстовые описания с trigger word "sophiaR"

---

## PHASE 5: УСТАНОВКА KOHYA_SS

### 5.1 Скачивание

- [ ] Перейти на GitHub: https://github.com/bmaltais/kohya_ss
- [ ] Code → Download ZIP
- [ ] Распаковать в удобное место (например `C:/AI/kohya_ss/`)

### 5.2 Установка

- [ ] Запустить `setup.bat` (Windows) или `setup.sh` (Linux/Mac)
- [ ] Дождаться установки всех зависимостей (10-30 минут)
- [ ] После завершения установки

### 5.3 Запуск GUI

- [ ] Запустить `gui.bat` (Windows) или `gui.sh` (Linux/Mac)
- [ ] Откроется браузер с интерфейсом Kohya
- [ ] Проверить что все вкладки доступны

**Время:** 30 минут - 1 час  
**Результат:** Рабочий Kohya GUI

---

## PHASE 6: ТРЕНИРОВКА LoRA

### 6.1 Настройка Source Model

- [ ] Открыть вкладку **Source model**
- [ ] Model: Выбрать ту же модель что использовали (Realistic Vision v6.0)
- [ ] v2: ☐ (для SD 1.5)
- [ ] v_parameterization: ☐

### 6.2 Настройка Folders

- [ ] Открыть вкладку **Folders**
- [ ] Image folder: `[путь]/Sophia_Dataset/images/`
- [ ] Output folder: `[путь]/Sophia_Dataset/output/`
- [ ] Model output name: `sophiaR_v1`
- [ ] Regularization folder: (оставить пустым пока)

### 6.3 Настройка Training Parameters

- [ ] Открыть вкладку **Training parameters**
- [ ] Network Rank (Dimension): **32**
- [ ] Network Alpha: **32**
- [ ] Learning rate: **0.0001**
- [ ] Text Encoder learning rate: **0.00005**
- [ ] Epochs: **10**
- [ ] Batch size: **2** (если GPU позволяет, иначе 1)
- [ ] Save every N epochs: **1**

### 6.4 Advanced Settings

- [ ] Открыть вкладку **Advanced**
- [ ] Optimizer: **AdamW8bit**
- [ ] Mixed precision: **fp16**
- [ ] Cache latents: ✅

### 6.5 Запуск тренировки

- [ ] Проверить все настройки еще раз
- [ ] Нажать кнопку **Train**
- [ ] Дождаться завершения (30 минут - 3 часа в зависимости от GPU)
- [ ] Следить за прогрессом в консоли
- [ ] После завершения проверить папку `output/`

**Файлы в output:**

- [ ] `sophiaR_v1-000008.safetensors`
- [ ] `sophiaR_v1-000009.safetensors`
- [ ] `sophiaR_v1-000010.safetensors`

**Время:** 1-4 часа  
**Результат:** Тренированный LoRA в нескольких версиях (epochs)

---

## PHASE 7: ТЕСТИРОВАНИЕ LoRA

### 7.1 Установка LoRA в Forge

- [ ] Скопировать файлы .safetensors из `output/`
- [ ] Вставить в `stable-diffusion-webui-forge/models/Lora/`
- [ ] Перезапустить Forge (или Refresh LoRA list)

### 7.2 Тестирование разных epochs

**Тест epoch 8:**

- [ ] Открыть txt2img
- [ ] Под промптом нажать 🎴 (Lora button)
- [ ] Выбрать `sophiaR_v1-000008`
- [ ] Промпт:

```
<lora:sophiaR_v1-000008:0.8>
sophiaR, 34 year old woman, green eyes, brown wavy hair,
beauty mark above lip, curvy athletic,
portrait, looking at camera, warm smile,
photorealistic, professional photography, natural lighting
```

- [ ] Generate 5 тестовых фото
- [ ] Оценить консистентность лица

**Тест epoch 10:**

- [ ] Повторить с `sophiaR_v1-000010`
- [ ] Сравнить с epoch 8

**Тест epoch 12 (если есть):**

- [ ] Повторить с `sophiaR_v1-000012`
- [ ] Сравнить со всеми

### 7.3 Выбор лучшего epoch

- [ ] Сравнить результаты всех epochs
- [ ] Критерии выбора:
  - [ ] Лицо стабильное (те же глаза, волосы, beauty mark)
  - [ ] НЕ переобучено (не копирует точные позы из датасета)
  - [ ] Хорошее качество
  - [ ] Реагирует на промпты (меняет позы, одежду)
- [ ] Выбрать лучший epoch (обычно 9-11)
- [ ] Переименовать в `sophiaR_final.safetensors`

### 7.4 Тестирование вариаций

**Тест разных поз:**

- [ ] `sophiaR, sitting on bed`
- [ ] `sophiaR, standing by window`
- [ ] `sophiaR, lying down`

**Тест разной одежды:**

- [ ] `sophiaR, wearing black lingerie`
- [ ] `sophiaR, wearing white silk robe`
- [ ] `sophiaR, casual outfit`

**Тест разного освещения:**

- [ ] `golden hour lighting`

- [ ] `soft bedroom lighting`

- [ ] `natural window light`

- [ ] Убедиться что лицо остается консистентным во всех вариациях

**Время:** 1-2 часа  
**Результат:** Выбран лучший LoRA файл, протестирована стабильность

---

## PHASE 8: ФИНАЛЬНАЯ ГЕНЕРАЦИЯ КОНТЕНТА

### 8.1 Подготовка промптов

- [ ] Создать файл `sophia_prompts.txt`
- [ ] Подготовить базовый template:

```
<lora:sophiaR_final:0.8>
sophiaR, 34 year old mature woman, green eyes, brown wavy hair, beauty mark above lip,
[OUTFIT], [POSE], [LOCATION],
photorealistic, professional photography, [LIGHTING]

Negative: cartoon, anime, young, tattoos, multiple people, low quality, blurry
```

### 8.2 Генерация первой библиотеки контента

**Категория 1: Teaser/SFW (10 фото)**

- [ ] Clothed, suggestive
- [ ] Face focus
- [ ] Lifestyle shots

**Категория 2: Lingerie (15 фото)**

- [ ] Black lingerie set (5)
- [ ] White/nude lingerie (5)
- [ ] Burgundy/colored (5)

**Категория 3: Topless/Artistic (15 фото)**

- [ ] Covered with hands/arms (5)
- [ ] From behind/side (5)
- [ ] Artistic angles (5)

**Категория 4: Explicit/Nude (10 фото)**

- [ ] Full body nude
- [ ] Various poses
- [ ] Different angles

### 8.3 Организация контента

- [ ] Создать папку `Sophia_Content/`
- [ ] Подпапки:
  - [ ] `1_Teaser_SFW/`
  - [ ] `2_Lingerie/`
  - [ ] `3_Topless_Artistic/`
  - [ ] `4_Explicit_Nude/`
- [ ] Сортировать сгенерированные фото по категориям
- [ ] Отобрать только лучшие (50-75 фото total)

### 8.4 Создание контент-календаря

- [ ] Создать файл `content_schedule.xlsx` или Google Sheets
- [ ] Спланировать первые 30 дней:
  - [ ] Какое фото в какой день
  - [ ] Тип контента (subscription feed vs PPV)
  - [ ] Caption ideas
- [ ] Подготовить captions для первых 10 постов

**Время:** 3-5 часов  
**Результат:** 50-75 готовых качественных фото для старта, организованных по категориям

---

## PHASE 9: ВАЛИДАЦИЯ И ФИНАЛИЗАЦИЯ

### 9.1 Quality Check всего проекта

- [ ] Проверить LoRA:
  
  - [ ] Лицо консистентное
  - [ ] Реагирует на промпты
  - [ ] Качество высокое
  - [ ] Работает с разными настройками

- [ ] Проверить контент-библиотеку:
  
  - [ ] 50+ качественных фото
  - [ ] Разнообразие категорий
  - [ ] Разнообразие поз/outfits
  - [ ] Все фото в высоком разрешении

- [ ] Проверить документацию:
  
  - [ ] Character concept document
  - [ ] Финальный промпт template
  - [ ] Лучшие settings записаны
  - [ ] Content schedule готов

### 9.2 Backup всего проекта

- [ ] Создать папку `Sophia_Project_Backup/`
- [ ] Скопировать:
  - [ ] LoRA файл (`sophiaR_final.safetensors`)
  - [ ] Весь датасет (`Sophia_Dataset/`)
  - [ ] Контент библиотеку (`Sophia_Content/`)
  - [ ] Все документы и промпты
- [ ] Сделать ZIP архив
- [ ] Сохранить на внешний диск или облако

### 9.3 Финальная проверка

- [ ] Сгенерировать 10 новых random фото
- [ ] Убедиться что все работает стабильно
- [ ] Записать финальные настройки:

```
Model: [название]
LoRA: sophiaR_final.safetensors
LoRA strength: 0.8
Steps: 30
CFG: 7
Sampler: DPM++ 2M Karras
Size: 512x768 или 768x768
```

**Время:** 1 час  
**Результат:** Проект полностью готов, все забэкаплено

---

## ✅ ГОТОВО: SOPHIA ПЕРСОНА СОЗДАНА

### Что у вас есть:

✅ **Тренированный LoRA** - консистентный персонаж Sophia  
✅ **50-75 готовых фото** - первая библиотека контента  
✅ **Промпт templates** - для будущей генерации  
✅ **Content strategy** - план на первый месяц  
✅ **Backup проекта** - все сохранено

### Следующие шаги:

1. **Setup платформ** (OnlyFans, Twitter, Reddit)
2. **Upload контента** и начало постинга
3. **Генерация нового контента** по мере необходимости
4. **Marketing & promotion** для роста аудитории

---

## ВРЕМЕННАЯ ОЦЕНКА

**Оптимистичный сценарий:** 2-3 дня (если все идет гладко)  
**Реалистичный сценарий:** 3-5 дней  
**С проблемами:** 5-7 дней

**Total time investment:** 15-25 часов

---

## TROUBLESHOOTING

### Если LoRA не работает:

- [ ] Проверить что trigger word "sophiaR" используется
- [ ] Попробовать разные strengths (0.6, 0.8, 1.0)
- [ ] Перетренировать с меньше epochs
- [ ] Добавить больше вариаций в датасет

### Если лицо не консистентное:

- [ ] Добавить больше фронтальных фото в датасет
- [ ] Увеличить Network Rank до 64
- [ ] Тренировать дольше (15 epochs)
- [ ] Улучшить качество датасета

### Если качество плохое:

- [ ] Проверить базовую модель (должна быть реалистичная)
- [ ] Увеличить steps до 40-50
- [ ] Использовать Hi-Res Fix
- [ ] Улучшить промпт (больше деталей)

---

**PROJECT STATUS:** [ ] Not Started → [ ] In Progress → [ ] Complete

**Start Date:** ___________  
**Completion Date:** ___________

---

*Документ создан для проекта Sophia Reed (sophiaR) - MILF GFE Character*  
*Version 1.0 - October 2025*