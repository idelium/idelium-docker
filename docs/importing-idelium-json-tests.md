# Importing Idelium JSON tests

Idelium supports a native JSON import format for creating a test and its reusable
steps from the web console. The import is useful when a test must be prepared in
source control, reviewed, and then loaded into a project from the UI.

The import workflow accepts native Idelium JSON definitions and Postman
collection JSON files. A Postman collection is converted into an executable
Idelium Postman step during import.

## How to test the public demo page

Use the ready-made example file:

```text
docs/examples/idelium-demo-test-import.json
```

Then open the web console:

1. Select the target project.
2. Open **Tests**.
3. Open **Import Idelium JSON**.
4. Upload `docs/examples/idelium-demo-test-import.json`.
5. Review the imported step list.
6. Click **Import Test**.
7. Add the imported test to a test cycle and launch it from **Test Launcher**.

The example creates a Selenium-runtime step that opens:

```text
https://idelium.org/demo/
```

## How to test the demo page with Idelium DSL

Use this DSL-based import when you want the same browser coverage expressed as
versioned Idelium DSL source:

```text
docs/examples/idelium-demo-dsl-test-import.json
```

The file is still an `idelium.test-import.v1` JSON document, so it is imported
from the same web-console workflow. Its executable action uses:

```json
{
  "stepType": "dsl",
  "runtime": "dsl",
  "schemaVersion": "dsl.source.v1",
  "languageVersion": "1.0"
}
```

The DSL example is split into multiple reusable Idelium steps, mirroring the
Selenium example sections. This keeps the execution results readable: the web
console shows separate entries for opening the page, verifying the hero area,
exercising forms, dynamic content, tables, widgets, pagination, fake login,
network controls, and the final screenshot.

The DSL example covers the browser component families that DSL v1 supports:
navigation, explicit waits, visibility checks, text/value assertions, counts,
clicks, text entry, conditionally visible widgets, pagination, storage controls,
network-status controls, flaky-state controls, and screenshots.

DSL v1 does not yet include dedicated commands for native select mutation,
browser alerts, iframe switching, Shadow DOM traversal, arbitrary JavaScript, or
Postman/Newman execution. Keep using the native JSON and Postman examples for
those advanced surfaces until the DSL language adds explicit commands for them.

## Import format

```json
{
  "schema": "idelium.test-import.v1",
  "name": "Idelium demo smoke test",
  "description": "Open the public Idelium demo page.",
  "steps": [
    {
      "name": "Open Idelium demo",
      "failedExit": true,
      "attachScreenshot": true,
      "steps": [
        {
          "stepType": "open_browser",
          "url": "https://idelium.org/demo/",
          "xpath": "//*",
          "note": "Open the Idelium demo page"
        }
      ]
    }
  ]
}
```

The top-level `steps` array defines the reusable Idelium steps that will be
created for the imported test. Each reusable step contains its executable
actions in its nested `steps` array.

## Postman collection import

You can also upload a Postman collection file directly, for example:

```text
docs/examples/Postman Echo.postman_collection.json
```

The web console converts the collection into an Idelium step with a
`postman_collection` action. Postman steps must include the collection payload;
empty Postman steps are rejected during import so the CLI can persist request,
assertion, timing, and response details for the execution results page.
