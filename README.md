[English](README.md) | [简体中文](README_ZH.md)

# lean-metric

**Less app, more note.**

A simple, note-like weight loss tracker built with Flutter.

`lean-metric` is a lightweight, privacy-focused app for recording your weight loss journey. Track your daily weight, sleep, meals, physical activity, and status in one place — just like keeping a personal notebook.

No pre-packaged bloated food databases. No calorie calculations. No unnecessary complexity.

Just record your day, stay consistent, and keep going.

## ✨ Philosophy

Weight loss doesn't have to be complicated, and tracking it shouldn't be either.

Many fitness apps come with extensive food databases, calorie calculators, and overwhelming analytics. `lean-metric` takes a simpler approach: give you a clean place to record the things that matter, without turning daily tracking into another task to manage.

- **Simple by design** — Focus on recording, not configuring.
- **Note-like experience** — Write down what you eat, how you sleep, and what activities you do.
- **Custom phrasebooks** — Build your own personal food and workout entries instead of searching through thousands of pre-set items.
- **No calorie counting** — No rigid food database or calorie calculations.
- **Water weight smoothing** — View your real weight trends with 7-day moving averages that smooth out daily water weight fluctuations.
- **100% Offline & Private** — All data is stored locally in SQLite on your device.

## 📋 Features

- **Daily Weight & Fasting Records** — Track daily weight and morning fasting state.
- **Flexible Sleep Logging** — Direct input for total sleep duration, with optional sleep/wake times and automatic calculation.
- **Steps Tracking** — Track daily step counts.
- **Meal & Activity Notes** — Quick multi-line notes for breakfast, lunch, dinner, other meals, exercise, and status.
- **Custom Preset Phrasebooks (词条库)** —
  - *Preset Diet*: Create personalized meal/food entries (e.g. `Protein Powder 30g`) for one-tap insertion into daily cards.
  - *Preset Training*: Organize custom strength and aerobic exercises (e.g. `Bench Press 60kg 5x10` or `Running 5km 25min`) with category tags.
- **Interactive Statistics & Trends** —
  - Weight trend charts powered by `fl_chart` with toggles between **Raw Data** and **Smoothed Weight** (7-day moving average).
  - Time range filtering (Past 30 days, Past 90 days, All time).
  - Weekly summary comparisons (This week vs. last week average weight, daily average steps, and average sleep duration).
- **Data Export** — Filter records by range (All, 7 days, 30 days, Custom) and export to clean, human-readable Markdown format.
- **Local Storage Management** — SQLite database storage with options to inspect cache size and clear local data.

## 🛠️ Tech Stack

- **[Flutter](https://flutter.dev/)** — Cross-platform UI toolkit
- **Dart** — Application logic
- **SQLite (`sqflite`)** — Local database persistence
- **`fl_chart`** — Data visualization and trend charts

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.13+)
- Dart SDK
- Android Studio or VS Code

### Run locally

```bash
git clone https://github.com/isNineSun/lean-metric.git
cd lean-metric
flutter pub get
flutter run
```

## 🗺️ Roadmap

- [x] Custom preset phrasebooks for meals and training
- [x] Interactive weight trend charts with water weight smoothing
- [x] Weekly data summary and comparative analysis
- [x] Markdown data export
- [ ] Goal weight setting and progress tracking
- [ ] Local JSON backup and restore

## 🤝 Contributing

Contributions, suggestions, and bug reports are welcome!

If you share the same preference for simple, practical tools, feel free to open an issue or submit a pull request.

## 📄 License

See [LICENSE](LICENSE) for license details.

---

**Less app, more note.**
