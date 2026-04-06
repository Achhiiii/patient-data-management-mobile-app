# Design System Specification: Clinical Precision & Tonal Depth

## 1. Overview & Creative North Star
### The Creative North Star: "The Ethereal Clinic"
The design system rejects the "utilitarian-industrial" look common in healthcare software. Instead, it adopts **The Ethereal Clinic** aesthetic—a high-end editorial approach that prioritizes cognitive ease through atmospheric layering. We move beyond the "grid-and-border" template by using intentional asymmetry and tonal depth. The goal is to make hospital staff feel empowered by a tool that feels as sophisticated and precise as the medical instruments they use daily. 

This system breaks the "template" look by utilizing **Manrope** for authoritative, large-scale headlines and **Inter** for high-performance data density, creating a rhythm of "Moments of Calm" (white space) and "Clusters of Action" (data grids).

---

## 2. Colors & Surface Philosophy
The palette is rooted in medical reliability but executed through an editorial lens. We avoid flat, dead colors in favor of "living" neutrals and deep, saturated primaries.

### Tonal Surface Hierarchy
| Token | HEX | Role |
| :--- | :--- | :--- |
| `surface` | #F7FAFC | The base canvas; represents sterile clarity. |
| `surface_container_low` | #F1F4F6 | Subtle recession for secondary background zones. |
| `surface_container_highest` | #E0E3E5 | Peak prominence for active workspace containers. |
| `primary` | #074469 | The "Command" color; used for core actions and brand presence. |
| `primary_container` | #2A5C82 | Soft-action backing; trustworthy and calm. |

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to section off areas. Boundaries must be defined solely through background color shifts. For example, a Patient Record sidebar should be `surface_container_low` sitting against a `surface` main content area. This creates a "soft-edge" layout that reduces visual noise and eye strain during long shifts.

### The "Glass & Gradient" Rule
To elevate the UI from "standard app" to "premium tool," use a subtle linear gradient on main Hero buttons or Patient Header backgrounds: 
- **Signature Gradient:** `primary` (#074469) top-left to `primary_container` (#2A5C82) bottom-right.
- **Glassmorphism:** Use `surface_container_lowest` at 80% opacity with a `backdrop-blur: 12px` for floating navigation bars or modal overlays.

---

## 3. Typography
The system uses a dual-font strategy to balance character and utility.

*   **Display & Headlines (Manrope):** Chosen for its modern, geometric structure. Large scales (`display-lg` at 3.5rem) should be used for patient names or critical status updates to provide an "editorial header" feel.
*   **Body & UI Labels (Inter):** A workhorse typeface designed for legibility at small sizes. All medical data, vitals, and logs must use Inter to ensure high readability under fluorescent hospital lighting.

**Hierarchy Note:** Use `headline-sm` (Manrope, 1.5rem) for section titles to provide a clear "anchor" for the eye before descending into the `body-md` (Inter, 0.875rem) data points.

---

## 4. Elevation & Depth
In this system, depth is a functional tool for hierarchy, not a decorative flourish.

*   **The Layering Principle:** Stack surfaces to create focus. Place a `surface_container_lowest` (#FFFFFF) card on a `surface_container_low` (#F1F4F6) background. This creates a natural "lift" that mimics physical paper.
*   **Ambient Shadows:** For floating elements (like a "New Entry" FAB), use a highly diffused shadow:
    *   `box-shadow: 0 12px 32px -4px rgba(24, 28, 30, 0.06);` 
    *   The shadow is tinted with the `on_surface` color to look natural and integrated.
*   **The "Ghost Border" Fallback:** If a border is legally or functionally required for accessibility, use the `outline_variant` token at **20% opacity**. Never use a 100% opaque border.

---

## 5. Components

### Cards & Data Lists
*   **Standard:** No dividers. Use **Spacing Scale 5** (1.1rem) to separate rows. 
*   **Separation:** Use a subtle background shift to `surface_container_highest` on hover to indicate interactivity.
*   **Nesting:** Patient vitals should be grouped in `surface_container_lowest` cards with `xl` (0.75rem) rounded corners.

### Buttons
*   **Primary:** Signature Gradient (Primary to Primary Container) with `md` (0.375rem) corners.
*   **Tertiary:** Transparent background with `on_primary_fixed_variant` text. Only appears on hover with a `surface_variant` fill.

### Input Fields
*   **Structure:** No bottom line or full box. Use a subtle `surface_container_highest` fill.
*   **States:** On focus, transition the background to `surface_container_lowest` and apply a 2px "Ghost Border" using `primary`.

### Specialized Healthcare Components
*   **Vitals Monitor:** Use `tertiary` (#5A3B00) for "Warning" states and `error` (#BA1A1A) for "Critical" states. These should be presented as soft-glow "Pills" rather than harsh icons.
*   **Timeline Scrubber:** A horizontal track using `surface_container_high` to navigate patient history, utilizing `full` rounded corners (9999px) for the handle.

---

## 6. Do’s and Don’ts

### Do
*   **DO** use whitespace as a separator. If you feel the need to add a line, add **Spacing Scale 4** (0.9rem) of padding instead.
*   **DO** use `label-sm` for metadata (e.g., timestamps) in `on_surface_variant` to keep the hierarchy clear.
*   **DO** embrace asymmetry. Aligning a patient photo to a non-standard grid position can create a sophisticated, custom feel.

### Don't
*   **DON'T** use pure black (#000000) for text. Use `on_surface` (#181C1E) for a softer, more premium contrast.
*   **DON'T** use "Standard" blue (#0000FF). Only use the specified tonal blues to maintain the "calm and trustworthy" atmosphere.
*   **DON'T** use sharp 90-degree corners. Everything must have at least the `DEFAULT` (0.25rem) roundness to feel approachable and safe.