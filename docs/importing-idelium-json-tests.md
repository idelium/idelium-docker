# Importing Idelium JSON tests

Idelium supports a native JSON import format for creating a test and its reusable
steps from the web console. The import is useful when a test must be prepared in
source control, reviewed, and then loaded into a project from the UI.

The import workflow accepts Idelium JSON definitions only.

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
