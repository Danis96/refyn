# Design Tokens

Project UI tokens and recurring component patterns. Use this file when `design activate` or `design ultra` is active, and prefer these values over inventing new ones unless the user asks for a redesign.

Source of truth:

- [lib/theme/app_colors.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_colors.dart)
- [lib/theme/app_typography.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_typography.dart)
- [lib/theme/app_spacing.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_spacing.dart)
- [lib/theme/app_theme.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_theme.dart)
- [lib/theme/app_button_styles.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_button_styles.dart)
- [lib/theme/app_card_styles.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_card_styles.dart)

## Typography

- Font family: default Flutter/Material font stack. No custom font declared in [pubspec.yaml](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/pubspec.yaml).
- `headlineLarge`: `32 / 1.2 / w700`
- `headlineMedium`: `24 / 1.2 / w700`
- `titleLarge`: `20 / 1.2 / w600`
- `titleMedium`: `16 / 1.3 / w600`
- `bodyLarge`: `16 / 1.4 / w400`
- `bodyMedium`: `14 / 1.4 / w400`
- `labelLarge`: `14 / 1.2 / w600`

Usage guidance from current code:

- Page hero / key summary text often pushes heavier than theme default, up to `w800` for emphasis, seen in [home_page.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/app/features/dashboard/ui/pages/home_page.dart:171)
- Receipt-style presentation uses uppercase merchant headers and monospace only for receipt-specific rows, seen in [receipt_paper_card.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/app/widgets/receipt_paper_card.dart:545)
- Standard info cards use `titleMedium` + `bodyMedium`, seen in [app_info_card.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/app/widgets/app_info_card.dart:17)

## Spacing

Base spacing scale from [app_spacing.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_spacing.dart):

- `xxs`: `4`
- `xs`: `8`
- `sm`: `11`
- `md`: `16`
- `lg`: `24`
- `xl`: `32`

Common layout usage:

- Default page padding: `16`, seen in [app_scaffold.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/app/widgets/app_scaffold.dart:10)
- Standard card padding: `16`
- Section gaps inside pages: mostly `16` or `24`
- Micro gaps inside dense receipt rows: `2` or `4`
- Hero section bottom padding: usually `24`

## Color Tokens

### Light

- background: `#F5F6FB`
- surface: `#FFFFFF`
- primary: `#15152A`
- onPrimary: `#FFFFFF`
- secondary: `#4F526B`
- error / danger: `#E0574E`
- success: `#2EBD73`

### Dark

- background: `#0F1020`
- surface: `#1A1B2D`
- primary: `#87A8FF`
- onPrimary: `#0D1330`
- secondary: `#BCC2E7`
- error / danger: `#E0574E`
- success: `#2EBD73`

Theme usage:

- Material 3 enabled
- Scaffold background uses background token
- Text theme uses light primary in light mode and white in dark mode
- Navigation indicator uses primary with alpha: `0.12` light, `0.20` dark

## Category Colors

Category accents from [category_palette.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/category_palette.dart):

- groceries: `#38A169` light, `#5FD08A` dark
- household: `#8B5E3C` light, `#C79A72` dark
- pets: `#E0B321` light, `#FFD96A` dark
- clothing: `#3A84F7` light, `#72AEFF` dark
- fuel: `#E76F51` light, `#FF9A73` dark
- pharmacy: `#0E9384` light, `#61D3C6` dark
- dental: `#2D9CDB` light, `#8FD3FF` dark
- miscellaneous/default: `#667085` light, `#ACB4C8` dark

Supporting category behavior:

- category surface uses primary with alpha: `0.32` light, `0.22` dark
- category track uses primary with alpha: `0.18` light, `0.24` dark
- category gradients fade from tinted accent into surface

## Radius

Project uses rounded surfaces heavily. Common radii:

- `8`: small chips / tiny surfaces
- `10`: compact pills, small inline surfaces
- `12`: primary button radius, standard compact card/button
- `14`: medium nested surfaces
- `16`: default card radius
- `18`: prominent content cards like scan and receipt surfaces
- `20`: larger settings containers
- `24`: large section edge or hero container edge
- `999`: pills, progress clips, badges

Prefer:

- default card radius: `16`
- primary CTA radius: `12`
- featured surface radius: `18`
- pill / badge radius: `999`

## Borders And Elevation

- Default card border: secondary color at `0.2` alpha
- Default card elevation: `0`
- Receipt card adds soft shadow: black at `0.04` alpha, blur `16`, y offset `6`
- Many custom feature cards rely more on border + tinted fill than strong shadow

## Buttons

Primary button from [app_button_styles.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/theme/app_button_styles.dart):

- horizontal padding: `24`
- vertical padding: `11`
- radius: `12`
- elevation: `0`
- text weight: `w600`
- colors: theme `primary` / `onPrimary`

Use:

- one dominant filled primary action per section
- icon buttons only when action is obvious from context
- pill buttons only for filters/badges, not main CTA

## Motion

Current motion pattern is subtle and short:

- animated switchers around `260ms`
- ease-out/ease-in cubic curves
- small slide offset on entrance, around `0.02`
- list/card entrance often uses fade + upward translation
- expandable receipt sections use animated size around `320ms`

Reference examples:

- [scan_surface_card.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/app/features/scan/ui/widgets/scan_surface_card.dart:154)
- [receipt_paper_card.dart](/Users/danispreldzic/Desktop/Danis/PROJECTS/reciept/lib/app/widgets/receipt_paper_card.dart:75)

## Practical Defaults

When adding UI and no stronger local pattern exists, default to:

- page padding: `16`
- vertical section gap: `16`, increase to `24` for major blocks
- card padding: `16`
- primary radius: `12`
- standard card radius: `16`
- featured card radius: `18`
- primary text color: theme text theme
- supporting text color: secondary or reduced-opacity primary text
- one accent at a time; use category colors only for category-driven UI

## Constraints

- Do not invent a custom font unless user asks
- Do not replace base palette without redesign request
- Do not add heavy shadows as default style
- Do not add gradients to list cards, category cards, or budget rows unless user explicitly asks for a featured/promotional treatment
- Preserve Material 3 + current theme structure
- Prefer existing `AppSpacing`, `AppColors`, `AppTypography`, and theme helpers over magic numbers
