+++
title = "What If You Could Test Drive a Terminal Theme?"
weight = 10

[extra]
date = "2026-03-29"
author = "YJ"
+++

Every few months I get the itch to switch terminal themes. The cycle is always the same: find something beautiful in a screenshot, spend 15 minutes editing kitty.conf and neovim configs, open a `git diff` — and realize the green-on-green is completely unreadable. Revert. Try the next one. Repeat.

On NixOS it's worse — every config change means a home-manager rebuild. A theme "test drive" becomes a 5-minute commit-build-evaluate loop, per theme, per app.

The problem isn't finding themes. It's that you can't see how one actually looks across your real workflow until you've fully committed to it. So I built [Litmus](https://litmus.edger.dev).

![Litmus showing Tokyo Night Day across multiple terminal scenarios](/images/litmus-hero.png)

## See everything before you change anything

Litmus captures real screenshots from real terminal emulators — kitty and wezterm — running real commands. Git diffs, cargo builds, bat highlighting, ripgrep output, shell prompts, ls, htop. 58 themes across 13 scenarios.

Pick any two themes and compare them side by side. No installation, no config editing, no terminal reloading.

![Side-by-side comparison of Tokyo Night and Flexoki Dark](/images/litmus-compare.png)

## Real output, not color swatches

Most theme previewers show you a palette — 16 colored squares. That tells you nothing about whether you can distinguish a compiler warning from an error, or whether git additions are readable against the background.

Litmus renders actual terminal output with the theme's colors applied. A deploy pipeline with pass/fail indicators. An editor with syntax-highlighted Rust. Every fixture runs the same commands you'd run in your daily workflow — what you see is what you get.

![Deploy pipeline fixture with CI status indicators](/images/litmus-color-showcase.png)

![Editor UI with syntax-highlighted Rust code](/images/litmus-editor-ui.png)

## The part I didn't expect

While building this, I realized theme previewing is also an accessibility problem. A theme that looks great to me might be unusable for someone with color vision deficiency.

So Litmus includes WCAG contrast checking on every color pair in every scene, and can simulate how themes look under protanopia, deuteranopia, and tritanopia. If you're picking a theme for a shared terminal session, a livestream, or a presentation — you can check that it works for everyone.

![Kanagawa Wave under normal vision](/images/litmus-normal.png)
![Kanagawa Wave simulated under deuteranopia](/images/litmus-deuteranopia.png)

## Try it

**[litmus.edger.dev](https://litmus.edger.dev)** — no signup, no install. Browse themes, compare them, export configs for your terminal.

Built with Rust and [Dioxus](https://dioxuslabs.com/), compiled to WebAssembly. Feedback welcome on [GitHub](https://github.com/edger-dev/litmus).
