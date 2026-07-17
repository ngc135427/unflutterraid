# 主页电源操作与下一波产品项

## Goal

在主页暴露安全的阵列级电源与校验操作，并诚实说明整机重启/关机不在当前 GraphQL schema。

## Requirements

- R1. Array start/stop via `array.setState` desiredState STARTED/STOPPED.
- R2. Stop requires typing STOP confirmation.
- R3. Parity check start (non-correcting) and cancel.
- R4. Busy state + refresh dashboard after success.
- R5. Copy notes OS reboot/shutdown not available via API.
- R6. Unit tests for mutations; analyze/test green.

## Out of Scope

- OS reboot/shutdown (schema unavailable).
- Correcting parity mode UI.
