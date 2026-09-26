# Deja un equipo listo para la memoria de Claude, nuevo o no: clona los repos que falten (repos.txt), enlaza la carpeta
# de memoria de Claude de cada proyecto con la suya aquí (y los alias de alias.txt con la de su proyecto), conecta cada
# repo con el índice de su memoria, aprueba esas importaciones, fusiona la configuración (config/settings-memoria.json),
# descifra los secretos (secretos/) y hace que ~/.claude/CLAUDE.md cargue este repositorio.
# Se puede correr las veces que sea: lo ya hecho no se toca.
# Uso: powershell -ExecutionPolicy Bypass -File enlazar.ps1 [-Raiz C:\Github] [-Solo <carpeta>]
#   -Solo: solo ese repo, sin clonar ni tocar lo demás (lo usa hooks/sesion-inicio.sh al abrir un repo).
param([string]$Raiz = 'C:\Github', [string]$Solo = '')

$central = $PSScriptRoot
$proyectos = Join-Path $HOME '.claude\projects'
$fecha = Get-Date -Format 'yyyyMMddHHmm'
$dueno = if ((git -C $central remote get-url origin 2>$null) -match 'github\.com[/:]([^/]+)/') { $Matches[1] } else { '' }   # dueño de este repo = dueño de los repos
$soloLocal = @(Get-Content (Join-Path $central 'solo-local.txt') -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_ -match '^[^#\s]' })   # privados sin rastro de Claude
$noProyecto = @('.git', 'compartidas', 'hooks', 'config', 'secretos')
$aprobados = Join-Path $HOME '.claude\memoria-claude-aprobados.txt'   # local: repos ya aprobados, para el hook
Add-Type -AssemblyName System.Web.Extensions
$json = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$json.MaxJsonLength = [int]::MaxValue
$utf8 = New-Object Text.UTF8Encoding $false   # sin BOM

function Enlazar([string]$carpeta, [string]$destino) {
    # Claude nombra la carpeta del proyecto con la ruta del repo, todo lo que no es letra o número pasa a '-': C:\Github\X-3.5 -> C--Github-X-3-5
    $nombre = (Join-Path $Raiz $carpeta) -replace '[^a-zA-Z0-9]', '-'
    $proyecto = Join-Path $proyectos $nombre
    $memoria = Join-Path $proyecto 'memory'
    New-Item -ItemType Directory -Force $proyecto | Out-Null

    if (Test-Path $memoria) {
        $item = Get-Item $memoria -Force
        if ($item.LinkType -eq 'Junction') {
            if (($item.Target | Select-Object -First 1) -eq $destino) { return }
            cmd /c rmdir "$memoria" | Out-Null          # quita solo el enlace, no su destino
        }
        elseif (Get-ChildItem $memoria -Force) {
            Rename-Item $memoria "memory.respaldo-$fecha"   # nunca se borra una memoria local
        }
        else { Remove-Item $memoria }
    }
    New-Item -ItemType Junction -Path $memoria -Target $destino | Out-Null
    Write-Output "enlazado: $nombre -> $(Split-Path $destino -Leaf)"
}

function Versionable([string]$repo, [string]$carpeta) {
    # CLAUDE.md versionado solo en repos privados propios. Sin gh o sin red: local, que no publica nada.
    if ($carpeta -in $soloLocal) { return $false }
    git -C $repo rev-parse -q --verify HEAD 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { return $false }   # repo vacío: el primer commit no lo hace este script
    $url = git -C $repo remote get-url origin 2>$null
    if ($url -notmatch "github\.com[/:]$dueno/([^/]+?)(\.git)?$") { return $false }
    $vis = gh repo view "$dueno/$($Matches[1])" --json visibility -q .visibility 2>$null
    return $vis -eq 'PRIVATE'
}

function QuitarLocal([string]$repo, [string]$linea) {
    # El import pasó al CLAUDE.md versionado: sale del CLAUDE.local.md, y el archivo se borra si no le queda nada.
    $local = Join-Path $repo 'CLAUDE.local.md'
    if (-not (Test-Path $local)) { return }
    $resto = @(Get-Content $local -Encoding UTF8 | Where-Object { $_ -ne $linea -and $_ -ne '# Memoria del proyecto (la pone enlazar.ps1 de memoria-claude)' })
    if (-not ($resto -match '\S')) { Remove-Item $local }
    else { [IO.File]::WriteAllText($local, ($resto -join "`n") + "`n", $utf8) }
}

function Conectar([string]$carpeta, [string]$proyecto, [bool]$esAlias = $false) {
    # Cada repo importa el índice de su memoria: en su CLAUDE.md versionado si es privado y propio, o en su
    # CLAUDE.local.md (nunca se versiona) si es público, ajeno, de solo-local.txt o un alias (worktree, clon de versión).
    # Así se carga también cuando el repo es un directorio adicional de la sesión.
    $repo = Join-Path $Raiz $carpeta
    if (-not (Test-Path (Join-Path $repo '.git'))) { return }
    $script:importados += $repo
    $linea = "@~/.claude/memoria-claude/$proyecto/MEMORY.md"
    $md = Join-Path $repo 'CLAUDE.md'
    if ((Test-Path $md) -and (Select-String -Path $md -SimpleMatch $linea -Quiet)) { QuitarLocal $repo $linea; return }

    if (-not $esAlias -and (Versionable $repo $carpeta)) {
        $bloque = "## Memoria de Claude`n`nEl estado, las decisiones y las preferencias de este repo viven en el repositorio privado " +
            "$dueno/memoria-claude (clonado en ~/.claude/memoria-claude). Este índice se carga en cada sesión:`n`n$linea`n"
        if (Test-Path $md) { [IO.File]::AppendAllText($md, "`n$bloque", $utf8) }
        else { [IO.File]::WriteAllText($md, "# $carpeta`n`n$bloque", $utf8) }
        QuitarLocal $repo $linea
        git -C $repo add -- CLAUDE.md
        git -C $repo commit -q -m 'chore: CLAUDE.md conecta el repo con su memoria en memoria-claude' -- CLAUDE.md
        $pendientes = @(git -C $repo log --oneline '@{u}..' 2>$null)
        if ($pendientes.Count -eq 1) { git -C $repo push -q 2>$null }
        if ($pendientes.Count -ne 1 -or $LASTEXITCODE -ne 0) { Write-Warning "${carpeta}: CLAUDE.md quedó en un commit local sin subir (hay otros commits pendientes o falló el push)" }
        Write-Output "importa su memoria: $carpeta\CLAUDE.md (versionado)"
        return
    }

    $local = Join-Path $repo 'CLAUDE.local.md'
    if (-not (Test-Path $local) -or -not (Select-String -Path $local -SimpleMatch $linea -Quiet)) {
        [IO.File]::AppendAllText($local, "# Memoria del proyecto (la pone enlazar.ps1 de memoria-claude)`n$linea`n", $utf8)
        Write-Output "importa su memoria: $carpeta\CLAUDE.local.md"
    }
    git -C $repo check-ignore -q CLAUDE.local.md 2>$null
    if ($LASTEXITCODE -ne 0) {
        $exclude = git -C $repo rev-parse --git-path info/exclude   # en worktrees es la ruta absoluta del repo principal
        if (-not [IO.Path]::IsPathRooted($exclude)) { $exclude = Join-Path $repo $exclude }
        New-Item -ItemType Directory -Force (Split-Path $exclude) | Out-Null
        [IO.File]::AppendAllText($exclude, "`nCLAUDE.local.md`n", $utf8)   # Add-Content en un archivo nuevo le pone BOM
    }
}

function Aprobar([string[]]$repos) {
    # El @import apunta fuera del repo y Claude lo ignora hasta aprobar las importaciones externas del proyecto
    # principal de la sesión (también rige para los adicionales). La CLI lo pregunta una vez; el app de escritorio
    # no, así que se aprueba aquí. Un proyecto que Claude nunca abrió no tiene entrada: lo aprueba el hook de inicio
    # la primera vez que se abre (su memoria carga desde la segunda sesión).
    $config = Join-Path $HOME '.claude.json'
    if (-not (Test-Path $config)) { return }
    $datos = $json.DeserializeObject([IO.File]::ReadAllText($config))   # sensible a mayúsculas, a diferencia de ConvertFrom-Json
    if (-not $datos.ContainsKey('projects')) { return }
    $cambios = 0
    $listos = @(if (Test-Path $aprobados) { Get-Content $aprobados })
    foreach ($repo in $repos) {
        foreach ($clave in @($repo, ($repo -replace '\\', '/'))) {   # Claude guarda el proyecto con \ y con /
            $p = $datos['projects'][$clave]
            if ($null -eq $p) { continue }
            if ($repo -notin $listos) { $listos += $repo }
            if ($p['hasClaudeMdExternalIncludesApproved'] -eq $true) { continue }
            $p['hasClaudeMdExternalIncludesApproved'] = $true
            $p['hasClaudeMdExternalIncludesWarningShown'] = $true
            $cambios++
        }
    }
    [IO.File]::WriteAllLines($aprobados, [string[]]$listos, $utf8)
    if ($cambios -eq 0) { return }
    Copy-Item $config "$config.respaldo-$fecha"
    [IO.File]::WriteAllText($config, $json.Serialize($datos), $utf8)
    Write-Output "importaciones de memoria aprobadas en ~/.claude.json: $cambios proyectos"
}

function Fusionar($destino, $origen) {
    # Agrega lo que falte sin pisar valores del equipo; en listas (hooks) agrega los elementos que no estén.
    $cambios = 0
    foreach ($k in @($origen.Keys)) {
        $d = $destino[$k]; $o = $origen[$k]
        if (-not $destino.ContainsKey($k)) { $destino[$k] = $o; $cambios++ }
        elseif ($d -is [Collections.IDictionary] -and $o -is [Collections.IDictionary]) { $cambios += Fusionar $d $o }
        elseif ($d -is [Array] -and $o -is [Array]) {
            # sin tubería: envolvería los elementos en PSObject y JavaScriptSerializer ya no podría escribirlos
            $ya = foreach ($x in $d) { $json.Serialize($x) }
            $nuevos = New-Object Collections.ArrayList
            foreach ($x in $o) { if ($json.Serialize($x) -notin $ya) { [void]$nuevos.Add($x) } }
            if ($nuevos.Count) { $destino[$k] = [object[]]$d + $nuevos.ToArray(); $cambios += $nuevos.Count }
        }
    }
    return $cambios
}

function Configurar {
    $origen = Join-Path $central 'config\settings-memoria.json'
    $settings = Join-Path $HOME '.claude\settings.json'
    if (-not (Test-Path $settings)) { Copy-Item $origen $settings; Write-Output "creado ~/.claude/settings.json"; return }
    $datos = $json.DeserializeObject([IO.File]::ReadAllText($settings))
    if ((Fusionar $datos ($json.DeserializeObject([IO.File]::ReadAllText($origen)))) -eq 0) { return }
    Copy-Item $settings "$settings.respaldo-$fecha"
    # ponytail: JavaScriptSerializer lo deja en una línea; basta para un equipo nuevo, formatearlo si molesta
    [IO.File]::WriteAllText($settings, $json.Serialize($datos), $utf8)
    Write-Output "fusionado config/settings-memoria.json en ~/.claude/settings.json (respaldo settings.json.respaldo-$fecha)"
}

function Descifrar {
    # secretos/archivos.txt: rutas relativas a $HOME. Cada una viaja cifrada con la llave pública
    # (secretos/destinatario.txt); la privada vive en OneDrive\Almacén personal (o en $env:MEMORIA_LLAVE).
    $lista = Join-Path $central 'secretos\archivos.txt'
    if (-not (Test-Path $lista)) { return }
    $llave = if ($env:MEMORIA_LLAVE) { $env:MEMORIA_LLAVE } else { Join-Path $env:OneDrive 'Almacén personal\memoria-claude-llave.txt' }
    foreach ($ruta in Get-Content $lista -Encoding UTF8 | Where-Object { $_ -match '\S' }) {
        $destino = Join-Path $HOME $ruta
        $cifrado = Join-Path $central ('secretos\' + (($ruta -replace '[\\/]', '__') -replace '^\.', '') + '.age')   # sin punto inicial
        if ((Test-Path $destino) -or -not (Test-Path $cifrado)) { continue }
        if (-not (Test-Path $llave)) { Write-Warning "no se descifró ${ruta}: desbloquea OneDrive\Almacén personal y vuelve a correr este script"; continue }
        $paquetes = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'   # recién instalado, el PATH de esta consola no lo trae
        $age = (Get-Command age -ErrorAction SilentlyContinue).Source
        if (-not $age) { $age = (Get-ChildItem $paquetes -Filter age.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName }
        if (-not $age) {
            winget install --id FiloSottile.age -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
            $age = (Get-ChildItem $paquetes -Filter age.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
        }
        New-Item -ItemType Directory -Force (Split-Path $destino) | Out-Null
        & $age -d -i $llave -o $destino $cifrado
        Write-Output "descifrado: $ruta"
    }
}

$importados = @()
$reposTxt = Join-Path $central 'repos.txt'   # <carpeta> <url>: de dónde clonar cada repo en un equipo nuevo
$carpetas = Get-ChildItem $central -Directory | Where-Object { $_.Name -notin $noProyecto -and (-not $Solo -or $_.Name -eq $Solo) }

if (-not $Solo) {
    $urls = @{}
    if (Test-Path $reposTxt) { Get-Content $reposTxt -Encoding UTF8 | Where-Object { $_ -match '^(\S+)\s+(\S+)$' } | ForEach-Object { $urls[$Matches[1]] = $Matches[2] } }
    foreach ($c in $carpetas) {
        $repo = Join-Path $Raiz $c.Name
        if (Test-Path (Join-Path $repo '.git')) { $urls[$c.Name] = git -C $repo remote get-url origin 2>$null }
        elseif ($urls[$c.Name]) { git clone -q $urls[$c.Name] $repo; Write-Output "clonado: $($c.Name)" }
    }
    $lineas = @($carpetas | Where-Object { $urls[$_.Name] } | ForEach-Object { "$($_.Name) $($urls[$_.Name])" })   # sin carpeta, fuera
    $actual = if (Test-Path $reposTxt) { [IO.File]::ReadAllText($reposTxt) } else { '' }
    $nuevo = ($lineas -join "`n") + "`n"
    if ($actual -ne $nuevo) { [IO.File]::WriteAllText($reposTxt, $nuevo, $utf8) }
}

$carpetas | ForEach-Object { Enlazar $_.Name $_.FullName; Conectar $_.Name $_.Name }

$alias = Join-Path $central 'alias.txt'
if (Test-Path $alias) {
    Get-Content $alias -Encoding UTF8 | Where-Object { $_ -match '^\s*([^#=\s][^=]*?)\s*=\s*(\S+)\s*$' } | ForEach-Object {
        if ($Solo -and $Matches[1] -ne $Solo) { return }
        $destino = Join-Path $central $Matches[2]
        if (Test-Path $destino) { Enlazar $Matches[1] $destino; Conectar $Matches[1] $Matches[2] $true }
        else { Write-Warning "alias.txt: no existe la carpeta de proyecto '$($Matches[2])'" }
    }
}
Aprobar $importados
if ($Solo) { return }

Configurar
Descifrar
$od = if ($env:OneDrive) { $env:OneDrive } else { Join-Path $HOME 'OneDrive' }
if (Test-Path $od) { New-Item -ItemType Directory -Force (Join-Path $od 'respaldos') | Out-Null }   # lo llena hooks/sesion-fin.sh

$precommit = Join-Path $central '.git\hooks\pre-commit'
if (-not (Test-Path $precommit)) {
    [IO.File]::WriteAllText($precommit, "#!/usr/bin/env bash`nexec bash `"`$(git rev-parse --show-toplevel)/hooks/pre-commit.sh`"`n")
    Write-Output "instalado el candado de secretos (pre-commit)"
}

$usuario = Join-Path $HOME '.claude\CLAUDE.md'
$import = '@~/.claude/memoria-claude/CLAUDE.md'
if (-not (Test-Path $usuario) -or -not (Select-String -Path $usuario -SimpleMatch $import -Quiet)) {
    [IO.File]::AppendAllText($usuario, "$import`n", $utf8)   # sin BOM: con él la línea no empieza con @ y no importa
    Write-Output "agregado a ~/.claude/CLAUDE.md: $import"
}
