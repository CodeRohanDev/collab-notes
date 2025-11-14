# CollabNotes - Modern Design Guide

## 🎨 Design System Overview

Your app now features a modern, professional design with a cohesive visual language across all screens.

## Color Palette

### Primary Colors
- **Primary**: `#6366F1` (Indigo) - Main brand color
- **Secondary**: `#8B5CF6` (Purple) - Accent and highlights
- **Accent**: `#EC4899` (Pink) - Special emphasis

### Semantic Colors
- **Success**: `#10B981` (Green) - Positive actions
- **Warning**: `#F59E0B` (Orange) - Alerts and guest mode
- **Error**: `#EF4444` (Red) - Errors and destructive actions

### Neutral Colors
- **Background**: `#F8FAFC` (Light gray)
- **Surface**: `#FFFFFF` (White)
- **Text**: Black87, Black54, Gray variants

## Gradients

### Primary Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [primaryColor, secondaryColor],
)
```
Used for: Splash screen, buttons, app bars

### Accent Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [secondaryColor, accentColor],
)
```
Used for: Special highlights and features

## Typography

### Display Styles
- **Display Large**: 32px, Bold, -0.5 letter spacing
- **Display Medium**: 28px, Bold, -0.5 letter spacing
- **Headline Large**: 24px, Bold

### Body Styles
- **Title Large**: 20px, Semi-bold (600)
- **Body Large**: 16px, Normal
- **Body Medium**: 14px, Normal

## Screen Designs

### 1. Splash Screen ✨

**Features:**
- Full-screen gradient background (Primary Gradient)
- Animated logo with scale and fade effects
- Circular container with glassmorphism effect
- Smooth loading indicator
- 2.5 second display duration

**Animations:**
- Logo: Scale from 0.5 to 1.0 with elastic curve
- Text: Slide up with fade in
- Duration: 2000ms

**Colors:**
- Background: Primary Gradient
- Icon: White with 20% opacity container
- Text: White

### 2. Onboarding Screen 📱

**Features:**
- 4 beautiful pages with smooth transitions
- Gradient circular containers for icons
- Expanding dots page indicator
- Gradient button with shadow
- Skip button in header

**Layout:**
- Header: App name + Skip button
- Content: Large circular icon container (200x200)
- Text: Title (28px) + Description (16px)
- Footer: Page indicator + CTA button

**Colors:**
- Background: Gradient (backgroundColor to white)
- Icon containers: Primary Gradient with shadow
- Button: Primary Gradient with 40% opacity shadow

**Animations:**
- Page transitions: 400ms ease-in-out cubic
- Dots: Expanding effect (3x expansion)

### 3. Welcome Screen 🎉

**Features:**
- Modern gradient background
- Circular logo with shadow
- Gradient text effect on app name
- Feature highlights with icons
- Two prominent CTAs (Sign in + Guest)
- Info banner for guest mode

**Layout:**
- Logo: Circular gradient container (64px icon)
- Title: Gradient shader mask effect
- Features: 3 rows with icons and text
- Buttons: Full-width with different styles
- Info: Rounded container with icon

**Colors:**
- Background: Gradient (backgroundColor to white)
- Logo: Primary Gradient with 30% shadow
- Sign In Button: Primary Gradient with shadow
- Guest Button: Outlined with primary color
- Info Banner: Primary color 10% opacity

### 4. Home Screen 🏠

**Features:**
- Expandable gradient app bar (120px)
- Guest mode banner (if applicable)
- Colorful note cards with gradients
- Floating action button with gradient
- Empty state with illustration
- Sync and menu options

**App Bar:**
- Height: 120px expandable
- Background: Primary Gradient
- Title: "My Notes" in white
- Actions: Sync button + Menu

**Guest Banner:**
- Orange gradient background
- Icon in colored container
- "Guest Mode" title
- Description text
- "Sign In" button

**Note Cards:**
- 5 different gradient color schemes
- Rounded corners (16px)
- Shadow effect matching card color
- Title, content preview, timestamp
- Sync indicator (if pending)
- Delete button

**Card Colors:**
1. Red tones: `#FFE5E5` to `#FFCCCC`
2. Blue tones: `#E5F3FF` to `#CCE7FF`
3. Orange tones: `#FFF3E5` to `#FFE7CC`
4. Green tones: `#E5FFE5` to `#CCFFCC`
5. Purple tones: `#F3E5FF` to `#E7CCFF`

**FAB:**
- Size: 64x64px
- Shape: Rounded (20px radius)
- Background: Primary Gradient
- Icon: Add (32px, white)
- Shadow: 40% opacity, 20px blur

### 5. Note Editor Screen ✍️

**Features:**
- Gradient background (subtle)
- Clean, distraction-free interface
- Title with gradient underline
- Auto-save indicator
- Floating save button (when edited)
- Back button with auto-save

**Layout:**
- App Bar: Back button + Title + Status badge
- Title Field: 28px bold, no border
- Divider: 2px gradient line
- Content Field: 16px, 1.6 line height
- FAB: Gradient check button (when edited)

**Status Badge:**
- Background: Success color 10% opacity
- Icon: Edit icon (16px)
- Text: "Editing" (12px, semi-bold)
- Color: Success color

**Save Button:**
- Size: 56x56px
- Shape: Rounded (16px)
- Background: Primary Gradient
- Icon: Check (28px, white)
- Shadow: 40% opacity, 20px blur

## Design Principles

### 1. Consistency
- Same border radius (12-16px) throughout
- Consistent spacing (8, 12, 16, 20, 24, 32px)
- Unified gradient usage
- Matching shadow styles

### 2. Hierarchy
- Clear visual hierarchy with size and weight
- Important actions use gradients
- Secondary actions use outlines
- Tertiary actions use text buttons

### 3. Feedback
- Loading states with spinners
- Success/error messages with colors
- Sync indicators on notes
- Edit status in note editor

### 4. Accessibility
- High contrast text
- Large touch targets (56px minimum)
- Clear labels and icons
- Readable font sizes (14px minimum)

### 5. Delight
- Smooth animations (200-400ms)
- Gradient effects
- Subtle shadows
- Rounded corners
- Colorful note cards

## Component Styles

### Buttons

**Primary (Gradient)**
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryColor.withOpacity(0.4),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
)
```

**Secondary (Outlined)**
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: AppTheme.primaryColor.withOpacity(0.3),
      width: 2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

### Cards

**Note Card**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [lightColor, darkerColor],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: lightColor.withOpacity(0.5),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

### Banners

**Info Banner**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

**Warning Banner (Guest Mode)**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppTheme.warningColor.withOpacity(0.1),
        AppTheme.warningColor.withOpacity(0.05),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppTheme.warningColor.withOpacity(0.3),
    ),
  ),
)
```

## Animations

### Timing
- **Fast**: 200ms - Small UI changes
- **Normal**: 300-400ms - Page transitions
- **Slow**: 500ms+ - Special effects

### Curves
- **easeInOut**: Standard transitions
- **easeOutBack**: Bouncy effects
- **elasticOut**: Spring effects
- **easeInOutCubic**: Smooth page changes

## Spacing System

- **xs**: 4px
- **sm**: 8px
- **md**: 12px
- **base**: 16px
- **lg**: 20px
- **xl**: 24px
- **2xl**: 32px
- **3xl**: 40px
- **4xl**: 48px

## Border Radius

- **Small**: 8px - Icons, badges
- **Medium**: 12px - Inputs, small cards
- **Large**: 16px - Cards, buttons
- **XLarge**: 20px - FAB, special elements

## Shadows

### Light Shadow
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 10,
  offset: Offset(0, 2),
)
```

### Medium Shadow
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 20,
  offset: Offset(0, 4),
)
```

### Colored Shadow (for gradients)
```dart
BoxShadow(
  color: AppTheme.primaryColor.withOpacity(0.4),
  blurRadius: 20,
  offset: Offset(0, 10),
)
```

## Best Practices

### Do's ✅
- Use gradients for primary actions
- Maintain consistent spacing
- Add shadows to elevated elements
- Use semantic colors appropriately
- Animate transitions smoothly
- Provide visual feedback

### Don'ts ❌
- Don't mix different border radius sizes randomly
- Don't use too many colors
- Don't make animations too slow
- Don't forget loading states
- Don't use harsh shadows
- Don't ignore accessibility

## Implementation

All design tokens are centralized in:
```
lib/core/theme/app_theme.dart
```

Import and use:
```dart
import 'package:collabnotes/core/theme/app_theme.dart';

// Colors
AppTheme.primaryColor
AppTheme.successColor

// Gradients
AppTheme.primaryGradient

// Text Styles
AppTheme.displayLarge
AppTheme.bodyMedium

// Theme
MaterialApp(theme: AppTheme.lightTheme)
```

## Future Enhancements

- [ ] Dark mode theme
- [ ] Custom font family
- [ ] More gradient variations
- [ ] Animated illustrations
- [ ] Micro-interactions
- [ ] Haptic feedback
- [ ] Sound effects
- [ ] Lottie animations

---

**Your app now has a beautiful, modern, professional design that users will love!** 🎉
