# CVAT Testing & Audit Report (Live Dev Stack)

This document details the system configuration, infrastructure fixes, and audit findings for both UI End-to-End (Cypress) and Backend API (Pytest) suites on the `arcbot-01` Tailscale development node.

---

## 1. System Architecture Overview

### Network Routing (Traefik)
- **Host Access:** The stack is accessible via `http://arcbot-01.husky-bangus.ts.net:8093`.
- **Local Access:** Cypress and internal tools use `http://localhost:8093`.
- **Routing Fix:** Traefik labels in `docker-compose.override.yml` handle both `localhost` and the Tailscale hostname.
- **Path Specificity:** API router (`cvat_server`) is restricted to prefixes `/api/`, `/static/`, `/admin/`, etc.

### Live View (VNC/noVNC)
- **Secure Stream:** Accessible at `https://arcbot-01.husky-bangus.ts.net:8443/vnc.html`.
- **Stack:** Nginx (SSL) -> websockify (Port 8097) -> x11vnc (Port 5900) -> Xvfb (Display :99).

---

## 2. Infrastructure Setup & Constraints

### Backend (Python/Pytest)
The backend tests manage their own Docker containers and require a clean environment.
1. **PyPI vs Local Shadowing:** **CRITICAL.** Do not use `pip install -e` for `cvat-sdk` or `cvat-cli` unless they are fully generated. The tests will fail with `ModuleNotFoundError` if local empty folders shadow the PyPI packages.
2. **Execution Directory:** Run `pytest` from the `tests/python` directory.
   ```bash
   cd tests/python && pytest .
   ```
3. **Container Conflict:** The backend suite REFUSES to start if original CVAT containers exist. Run `docker compose down` first.

### Frontend (Yarn 4 / Cypress)
- **Zero Repo Modification:** Config is injected via CLI flags (`--config`, `--env`) to keep the repo clean.
- **Ordered Execution:** Must follow the sequence in `run_ui_tests_sequential.sh` to build database state correctly.

---

## 3. Audit Findings: System vs. Repository

### System-Level Findings (Fixed via Override)
- **Worker Volume Mounts:** Fixed `FileNotFoundError` by mounting `./tests/mounted_file_share` to all workers.
- **Hostname Hairpinning:** Resolved 502/404 errors by adding `localhost` to Traefik router rules.
- **Performance Timeouts:** Optimized for Tailscale lag by increasing `defaultCommandTimeout` to 30,000ms.

### Repository-Level Findings (Bugs Identified)
1. **`tests/cypress/plugins/index.js`**: **CRITICAL BUG.** Line 54 lacks a check for `set-cookie`. Crashes the suite on login failure.
2. **`slice_join.js`**: Functional regression where original shapes are not removed after slicing.
3. **`bulk_actions.js`**: Reference to missing "public" resource.
4. **`cli/test_cli_tasks.py`**: Legacy alias failures in the backend suite.

---

## 5. Automated Setup (Ansible)

To quickly provision a fresh Linux workstation for CVAT development and testing:
1. Ensure Ansible is installed: `sudo apt install ansible`
2. Run the playbook:
   ```bash
   cd dev/automation/ansible
   ansible-playbook setup_dev_env.yml
   ```
This will configure your Docker overrides, Python virtual environment, and the sequential test runner automatically.

## 6. Maintenance Commands
- **Check UI Audit:** `tail -f /home/arika/cvat/tests/sequential_run.log`
- **Check Backend Audit:** `tail -f /home/arika/cvat/tests/backend_run.log`
- **Restart UI Runner:** `./run_ui_tests_sequential.sh`
- **Start Backend Runner:** `cd tests/python && pytest .`
- **Cleanup:** `pkill -9 -f cypress && pkill -9 -f electron`
