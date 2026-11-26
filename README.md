# Bastión Seguridad: lanzador del laboratorio

Laboratorio web deliberadamente vulnerable para las prácticas de auditoría web y seguridad en LLM del máster. Este repositorio solo contiene el lanzador: la aplicación se descarga como imagen de Docker.

**No lo expongas a Internet.** Contiene vulnerabilidades reales a propósito.

## Requisitos

- Windows o macOS: Docker Desktop
- Linux: Docker Engine con el plugin Compose

## Arranque

Descarga el repositorio (botón *Code > Download ZIP* o `git clone`) y, dentro de la carpeta:

| Sistema | Comando |
|---|---|
| Windows (PowerShell) | `./start.ps1 -Modo local` |
| Linux / macOS | `./start.sh local` |

Abre `http://localhost:8800` en el navegador integrado de Burp Suite.

Si PowerShell bloquea el script, ejecútalo una vez con:

```powershell
powershell -ExecutionPolicy Bypass -File .\start.ps1 -Modo local
```

## Operaciones habituales

| Acción | Comando |
|---|---|
| Ver registros | `docker compose logs -f` |
| Parar | `docker compose down` |
| Reiniciar desde cero (borra tus datos) | `docker compose down -v` y volver a arrancar |
| Actualizar a la última versión | `docker compose pull` y `docker compose up -d` |

## Modo compartido (profesor)

`./start.ps1 -Modo shared` publica el laboratorio en la red del aula, genera un token de profesor y flags únicas para la instancia. El panel de profesor está en `/profesor`.
