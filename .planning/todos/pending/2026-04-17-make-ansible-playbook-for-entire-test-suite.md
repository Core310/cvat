---
created: 2026-04-17T04:19:12.623Z
title: Make ansible playbook for entire test suite
area: testing
files:
  - README_TESTING.md
  - run_ui_tests_sequential.sh
  - docker-compose.override.yml
---

## Problem

Setting up the CVAT test environment requires multiple complex manual steps: configuring port 8093, updating Traefik labels for localhost/Tailscale routing, mounting shared volumes for worker containers, and installing/configuring X11 tools (Xvfb, x11vnc, noVNC, Nginx) for the Live View debugging stack. This makes it difficult to reliably reproduce the testing environment on other developer nodes.

## Solution

Create a structured Ansible playbook that automates the entire setup process:
1.  Install necessary system dependencies (Xvfb, x11vnc, noVNC, fluxbox, Nginx, tmux).
2.  Configure Nginx as a secure proxy for noVNC using Tailscale SSL certificates.
3.  Automatically generate/verify the `docker-compose.override.yml` with correct port mappings and worker volume mounts.
4.  Ensure the `run_ui_tests_sequential.sh` script is present and configured with the correct `baseUrl`.
