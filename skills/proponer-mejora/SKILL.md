---
name: proponer-mejora
description: Propone a la plantilla pública del arnés una mejora general (una práctica, un arreglo, una idea) como issue en GitHub. Úsala cuando el usuario diga "propón esto a la plantilla" o "esto le serviría a todos".
---

# Proponer una mejora a la plantilla

1. Redacta la versión **general** de la mejora: la regla o el cambio, el porqué y cómo aplicarlo, sin nada del usuario
   ni de sus proyectos (nombres de personas, clientes o empresas, correos, rutas, servidores, montos). Si es una nota,
   con el mismo formato que las de `compartidas/`.
2. Muéstrasela completa y pregunta si la manda así. Es público: nada sale sin su sí.
3. Repo de la plantilla: el del remoto `plantilla` (`git -C ~/.claude/memoria-claude remote get-url plantilla`).
   `gh issue create -R <dueño>/<repo> --title "<título corto>" --body-file <archivo>`.
4. Dale el enlace del issue. El dueño de la plantilla lo revisa y, si entra, llega a todos con "actualiza el arnés".
