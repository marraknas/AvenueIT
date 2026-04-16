---
name: Keep changes minimal and in-place
description: User prefers small, focused edits over new files or over-engineered solutions
type: feedback
---

Keep changes scoped to the smallest reasonable footprint. Don't create new files when an inline edit will do.

**Why:** User explicitly rejected a new LocationPickerView.swift file in favour of a simple inline enum + picker in the existing HomeView.swift.

**How to apply:** Before creating a new file, ask whether the change can live inline in the existing file. Prefer simple enums, small helper views, or inline state over new file abstractions unless the user asks for it.
