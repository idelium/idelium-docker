# Idelium Console UX/UI Roadmap

Date: July 28, 2026

Audience: Product Owner, UX/UI Design, Frontend Engineering, QA, Automation Architecture, DevOps, and Security.

Objective: evolve the Idelium console from a technically complete and visually distinctive interface into an enterprise product that is efficient, accessible, governable, scalable, and safe for regulated teams.

## Executive assessment

Idelium already has a recognizable product identity: dark theme, orange brand accent, persistent shell, sidebar navigation, project/customer context, and a technical tone that fits an automation platform.

The gap is not visual identity. The gap is enterprise consistency:

- information architecture is partially structured;
- usability is uneven across legacy CRUD pages and newer enterprise pages;
- governance and security UX need stronger guardrails;
- accessibility and large-dataset behavior must become product requirements;
- complex authoring flows need alternatives to drag-and-drop and raw JSON.

The current console is suitable for technical demos and small teams that already understand the Idelium model. Enterprise customers need predictable navigation, safe change management, deep linking, auditability, keyboard access, scalable grids, and clear operational diagnostics.

## Product principles

The redesign should optimize for these enterprise behaviors:

1. The active customer and project are always visible.
2. Complex assets can be created without knowing internal JSON shapes.
3. Tables remain efficient with hundreds or thousands of records.
4. Costly mistakes are prevented before execution starts.
5. Credentials, launches, approvals, and destructive actions are auditable.
6. Unauthorized actions are hidden or safely disabled.
7. Failures can be diagnosed from run to worker, test, and step.
8. Keyboard, screen reader, and high-zoom usage are first-class workflows.
9. Terminology, states, colors, and actions are consistent across the product.
10. Destructive or irreversible operations are explicit and recoverable when possible.

## Strengths to preserve

- Dark enterprise theme and Idelium orange as the primary brand accent.
- Persistent shell and clear active navigation state.
- Card and panel-based layouts for operational surfaces.
- Bilingual support.
- Separation between configuration, launch, execution, and observability.
- The entity model: Customer → Project → Environment / Plugin / Step → Test → Test Cycle → Execution.
- Visual builders for test and test-cycle composition.
- Execution observability patterns already introduced in the executions/results area.

## Cross-cutting problems to solve

### Typography and readability

Current small uppercase labels and heavy letter spacing look technical but reduce readability in long operational sessions.

Required direction:

- base body text no smaller than 14 px;
- 16 px for primary forms;
- uppercase reserved for eyebrows, badges, and compact technical labels;
- line-height of at least 1.4;
- monospace only for code, commands, identifiers, and technical values;
- a shared hierarchy for page title, section title, label, helper, and caption.

### Action color semantics

Every action color must have one stable meaning:

| Function | Color semantics |
|---|---|
| Page primary action | Idelium orange |
| Secondary action | Neutral / outline |
| Success state | Green |
| Information / running | Blue |
| Warning | Amber |
| Destructive action | Red |
| Disabled | Neutral with sufficient contrast |

Each page should expose one obvious primary action whenever practical.

### Data density and page structure

Enterprise pages should use space for context, filters, metadata, and actions rather than leaving large empty surfaces.

Required direction:

- page header with title, description, and primary action;
- toolbar with search, filters, and density where useful;
- full-width operational tables;
- form pages constrained to readable max-width;
- intentional empty, loading, no-results, error, and permission states;
- summary panels only when they add operational value.

### Forms

Placeholders must never be the only field label.

Every field should support:

- persistent label;
- required/optional indicator;
- helper text;
- example or placeholder;
- valid/invalid state;
- inline error message;
- contextual documentation;
- `aria-describedby`;
- prefix, suffix, or unit when needed.

### Icon-only actions

Icon-only controls need:

- accessible tooltip;
- explicit `aria-label`;
- target size of at least 40 × 40 px;
- visible focus state;
- semantic action color;
- text labels for high-impact operations;
- confirmation for destructive, revocation, rotation, and irreversible actions.

### Composition flows

Drag-and-drop must never be the only way to compose tests or steps.

Required direction:

- checkbox and multi-select;
- add/remove selected controls;
- move up/down controls;
- keyboard reorder;
- visible drag handles;
- sequence numbering;
- screen-reader announcement of position changes;
- undo for the last structural edit.

### Shared states

The UI must distinguish:

- initial loading;
- background refresh;
- empty state;
- no results after filtering;
- recoverable error;
- permission denial;
- expired session;
- completed operation.

Shared components should include `SkeletonTable`, `EmptyState`, `InlineError`, `PageError`, `ButtonLoadingState`, `Toast`, and `OperationProgress`.

### Unsaved changes

Builders and complex forms must protect work in progress:

- centralized dirty-state contract;
- visible unsaved-changes badge;
- route/customer/project change confirmation;
- draft autosave only where product-approved;
- last-saved timestamp.

## Recommended information architecture

Primary navigation should be grouped by operational intent:

- Run: Test launcher, Executions, Results.
- Design: Tests, Steps, Plugins.
- Configure: Environments, Platforms, API credentials.
- Govern: Projects, Customers, Accounts, Audit.

Customer and project context should be part of the URL and visible in the app shell. Deep links must survive refresh and should preserve tab, filters, selected entity, and detail state.

## Shared design-system scope

The console needs reusable design tokens and shared components before additional page-level polish.

Core tokens:

- colors and semantic color aliases;
- typography scale;
- spacing scale;
- border radius;
- shadows;
- focus rings;
- z-index layers;
- motion durations.

Priority shared components:

- AppShell;
- PageHeader;
- EnterpriseDataTable;
- EntityPicker;
- Tabs;
- FormField;
- Select;
- Modal/Dialog;
- ConfirmDialog;
- Toast;
- EmptyState;
- InlineError;
- PageError;
- StatusBadge;
- ActionMenu;
- DetailDrawer;
- SequenceBuilder.

## Page-level roadmap

### Login

The login page should align visually with the enterprise shell, support language selection, remember-password preference, safe validation messages, and avoid third-party trust images that are not part of the product design system.

### Projects

Projects need enterprise CRUD forms, server-side grids, clear descriptions, ownership metadata, archive/restore behavior, and deep links scoped by project ID.

### Customers

Customer terminology must replace legacy misspellings in UI copy while preserving API compatibility through explicit aliases and migration notes.

### Accounts and roles

Account management must support invitation-based onboarding, invited/active/suspended statuses, role explanations, permission matrix, last-administrator protection, lifecycle confirmation, audit history, and safe localization.

### Test cycles

Test-cycle authoring should become a wizard:

1. metadata;
2. select tests;
3. configure sequence;
4. review and save.

The flow must support keyboard composition, search, duplicate detection, undo, and dirty-state protection.

### Tests

Test authoring should use the shared sequence builder, support import preview, validation, step ordering, accessible composition controls, and large available-step lists.

### Reusable steps

Step authoring should provide an action catalog, mode selection, schema-driven forms, DSL support, JSON validation, environment-based test execution, and impact summary before update.

### Environments

Environment configuration should support templates, variables, secret references, sectioned forms, connection tests, resolved previews, clone, dirty-state, and safe export.

### Plugins

Plugin management should support import validation, manifest preview, versioning, sandbox/runtime constraints, approval status, and audit.

### Test launcher

Launch must include required cycle, environment, target, and concurrency selection; preflight checks; idempotent launch; CLI command copy; and actionable errors without losing draft data.

### Executions and results

Execution observability should provide live runs, history filters, status not based only on color, cancel with confirmation, run-to-step drilldown, artifacts, reports, retry, rerun, and refresh-safe deep links.

### Platforms and execution targets

Platforms should expose target health, browser/device metadata, capability constraints, pools, and clear availability states.

### API credentials

Credential UX must provide named credentials, scopes, expiration, reveal-once, copy/download only at creation time, rotation, revocation, last-used metadata, and audit.

### Profile

Profile should show account identity, tenant/project context, role, password update, session/security state, and enterprise card layout.

## Enterprise patterns for every entity

Every major entity should support the applicable subset of:

- ownership and team metadata;
- tags and saved views;
- versioning;
- draft / publish / archive;
- audit trail;
- bulk operations;
- soft delete and restore.

## Accessibility requirements

The console must support:

- full keyboard navigation;
- visible focus ring;
- accessible names for icon buttons;
- semantic headings;
- table header and row relationships;
- form label/error relationships;
- screen-reader announcements for loading, validation, reorder, and operation completion;
- at least 200% zoom without horizontal traps;
- status that is not color-only.

## Responsive requirements

The console should support:

- desktop-first enterprise layouts at 1280, 1440, and 1920 px;
- usable tablet layouts for review and lightweight edits;
- mobile fallback for status, approvals, and urgent operations;
- drawer navigation and stacked cards on small screens;
- fullscreen editors where space is constrained.

## Priority roadmap

### P0 — Foundations and immediate risk

- API credential reveal-once, scope, revoke, and rotation.
- FormField with labels and validation.
- Shared color and button semantics.
- Confirm and soft-delete for destructive actions.
- Customer/project context switcher.
- Unsaved changes guard.
- Base accessibility: fonts, contrast, focus, keyboard.
- Shared loading, empty, and error states.
- Customer terminology correction.

### P1 — Core-flow efficiency

- New app shell and grouped navigation.
- Shared enterprise data table.
- Accessible test-cycle builder.
- Test builder and import preview.
- Three-panel step editor.
- Sectioned environment builder with connection test.
- Launch configuration with preflight.
- Run history and run detail.

### P2 — Enterprise governance

- Versioning and rollback.
- Draft/publish/approval.
- Audit trail.
- Account invitation, suspension, and RBAC matrix.
- Plugin lifecycle and validation pipeline.
- Environment secrets and inheritance.
- Execution target health and pools.
- Bulk actions, tags, and saved views.

### P3 — Optimization and insight

- Compare runs.
- Flaky-test analytics.
- Duration trends.
- Personal dashboard.
- Schedule management.
- Notification center.
- Command palette.
- Customizable columns.
- Saved launch profiles.
- Guided onboarding.

## Code-ready epics

### UX-01 — Design system foundation

Scope: tokens, typography, colors, spacing, status, buttons, form field, dialog, toast, and empty states.

Acceptance criteria:

- no new component introduces hard-coded colors outside tokens;
- every primary action uses the same variant;
- every field has an associated label and error message;
- focus ring is visible on every control;
- components are documented with examples and states;
- visual tests exist for supported themes.

### UX-02 — App shell and context navigation

Scope: grouped sidebar, context switcher, breadcrumbs, user menu, responsive drawer, and unsaved-change protection.

Acceptance criteria:

- active customer and project are always visible;
- context changes update the URL;
- unsaved changes block context changes;
- unauthorized navigation entries are not shown;
- sidebar is keyboard-usable;
- layout works at 1280, 1440, and 1920 px.

### UX-03 — Enterprise DataTable

Scope: shared table for Projects, Customers, Accounts, Steps, Environments, Plugins, Platforms, and Executions.

Acceptance criteria:

- search, sort, and pagination;
- filters persisted in URL;
- accessible row actions;
- empty and no-results states are distinct;
- loading skeleton;
- column visibility and density;
- optional bulk selection;
- sticky header for long datasets;
- tests with at least 1,000 simulated records.

### UX-04 — Sequence builder

Scope: common builder for Test Cycle → Tests and Test → Steps.

Acceptance criteria:

- add through drag, double click, checkbox, and button;
- keyboard reorder;
- persistent numbering;
- search and filters;
- duplicate detection;
- remove and undo;
- dirty state;
- pre-save validation;
- performance with at least 500 available and 100 selected elements.

### UX-05 — Reusable step editor

Scope: action catalog, sequence canvas, properties inspector, Wizard/JSON/DSL, and validation.

Acceptance criteria:

- catalog search;
- runtime grouping;
- add/edit/remove actions;
- schema-driven form;
- JSON validation with error path;
- DSL diagnostics with line and column;
- mode-conversion warning;
- test step against environment;
- impact summary before update.

### UX-06 — Environment configuration

Scope: templates, sectioned form, variables, secret references, connection test, and resolved configuration.

Acceptance criteria:

- Web/App/API templates;
- field and JSON validation;
- secrets never shown in export;
- connection result and remediation;
- clone;
- sticky save;
- resolved preview;
- dirty-state and route guard.

### UX-07 — Launch and preflight

Scope: new launch configuration page.

Acceptance criteria:

- cycle, environment, target, and concurrency required;
- blocking and non-blocking preflight checks with severity;
- configuration summary;
- idempotency and loading state;
- redirect to created run;
- copy CLI command;
- actionable errors without losing entered data.

### UX-08 — Execution observability

Scope: live runs, run history, detail tabs, worker progress, test/step results, and reports.

Acceptance criteria:

- historical filters;
- live progress with last-updated state;
- status not based only on color;
- cancel with confirmation and cancelling state;
- drilldown from run to worker/test/step;
- downloadable artifacts and reports;
- retry failed and rerun where supported;
- deep links preserved after refresh.

### UX-09 — Credential management

Scope: named credentials, scopes, expiration, reveal-once, rotation, and audit.

Acceptance criteria:

- complete secret appears once only;
- listing shows prefix/fingerprint, never full value;
- revoke and rotate require confirmation;
- last-used and expiration visible;
- copy/download available only in the creation result;
- CI snippet does not contain the secret;
- audit event for create, rotate, and revoke.

### UX-10 — Accounts and role governance

Scope: invitation, status, suspension, role descriptions, and audit.

Acceptance criteria:

- invite without administrator-chosen password;
- last-admin protection;
- invited/active/suspended statuses;
- permission descriptions in role picker;
- search and filter;
- account change audit;
- duplicate email and invalid tenant errors are handled safely.

## Suggested frontend mapping

| Area | Shared components |
|---|---|
| Shell | AppShell, ContextSwitcher, Breadcrumbs, UserMenu |
| Listings | EnterpriseDataTable, EmptyState, InlineError, ActionMenu |
| Forms | FormField, Select, SchemaForm, ConfirmDialog |
| Builders | SequenceBuilder, EntityPicker, DetailDrawer |
| Execution | RunTimeline, ResultTable, ArtifactPanel, ReportExport |
| Security | CredentialResult, RevealOncePanel, AuditHistory |

## Rollout strategy

1. Build foundations without changing business behavior.
2. Migrate one page at a time to shared components.
3. Preserve legacy API aliases during terminology migration.
4. Add tests before migrating high-risk flows.
5. Use feature flags where user workflows may change materially.
6. Document rollback and compatibility for each release.

## Success metrics

- time to create a valid test cycle;
- number of failed launches caused by configuration mistakes;
- time to diagnose a failed run;
- percentage of pages using shared components;
- accessibility defects per release;
- unbounded table-load regressions;
- credential exposure incidents;
- support requests related to navigation or terminology.

## What not to do

- Do not redesign only the colors while leaving legacy interaction patterns unchanged.
- Do not make drag-and-drop the only authoring path.
- Do not expose secrets in screenshots, snippets, exports, logs, or local storage.
- Do not add more raw JSON surfaces without validation, preview, and schema help.
- Do not hide destructive operations behind ambiguous icons.
- Use `idelium.org` for every public Idelium reference.

## Conclusion

Idelium has a strong foundation for an enterprise automation console. The next step is to make the interface systematically governable: shared components, scalable tables, accessible builders, explicit security UX, traceable lifecycle actions, and predictable operational diagnostics. The UX-01 through UX-10 epics define the implementation path for that transition.
