# Security Policy

## Supported version

Security fixes are applied to the latest `main` branch.

## Reporting a vulnerability

Use GitHub's private security-advisory feature for vulnerabilities. Do not open a public issue with credentials, production data, exploit details, or database dumps.

Include the affected commit, reproduction steps using synthetic data, impact, and a proposed mitigation if available. Maintainers will acknowledge a complete report as soon as practical.

## Scope

This repository is a local analytics laboratory. It does not provide production authentication, network encryption, backup encryption, secret management, or a complete role-provisioning model. The example RLS policy demonstrates database enforcement but still requires trustworthy application identity and connection-pool handling.
