#!/usr/bin/env python3
"""Arnés de memoria-claude (Windows, Mac y Linux).

  python arnes.py instalar [--raiz DIR]    deja el equipo listo: clona los repos de repos.txt que falten, enlaza la
                                           carpeta de memoria de Claude de cada proyecto con la suya aquí (y los alias
                                           de alias.txt), fusiona config/settings-memoria.json, descifra secretos/,
                                           instala el candado de secretos y hace que ~/.claude/CLAUDE.md cargue este
                                           repositorio.
  python arnes.py conectar CARPETA         solo ese repo (lo usa hooks/sesion-inicio.sh al abrir un repo nuevo).
  python arnes.py retomar [ID]             resume las sesiones cortadas por límite de uso de los últimos 7 días (o la
                                           sesión ID) para seguir en otra cuenta o en un chat nuevo.
  python arnes.py revisar --cwd C --sesion S   lo usa el hook de inicio: sesiones de esa carpeta cortadas por límite
                                           (retomar) y, una vez al día, índices que pasan del presupuesto y versión
                                           nueva del arnés.
  python arnes.py doctor                   revisa que todo esté en su lugar y dice cómo arreglar lo que falte.
  python arnes.py actualizar [--aplicar]   (copias de la plantilla) trae la versión nueva del arnés sin tocar lo
                                           propio; sin --aplicar solo muestra las novedades y qué cambiaría.

Se puede correr las veces que sea: lo ya hecho no se toca. --raiz: dónde están los repos (por omisión MEMORIA_RAIZ,
o C:\\Github en Windows y ~/Github en Mac y Linux).
"""
import argparse
import datetime
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

WIN = os.name == 'nt'
CENTRAL = Path(__file__).resolve().parent
HOME = Path.home()
CLAUDE = HOME / '.claude'
FECHA = datetime.datetime.now().strftime('%Y%m%d%H%M')
NO_PROYECTO = {'compartidas', 'hooks', 'config', 'secretos', 'docs', 'plantillas', 'skills'}   # y las que empiezan con punto
MARCA = '/.claude/memoria-claude/'   # entradas de settings.json que son del arnés
PRESUPUESTO = 4096                   # bytes por índice que se carga en cada chat (~1.1 mil tokens)
LINEA_MAX = 150                      # caracteres por línea de índice


def leer(p):
    return Path(p).read_text(encoding='utf-8-sig')   # -sig: tolera un BOM puesto por otro editor


def escribir(p, texto):
    with open(p, 'w', encoding='utf-8', newline='\n') as f:   # sin BOM: con él un @import deja de ser la primera cosa
        f.write(texto)


def escribir_json(p, datos):
    escribir(p, json.dumps(datos, indent=2, ensure_ascii=False) + '\n')


def lista(nombre):
    p = CENTRAL / nombre
    return [l.strip() for l in leer(p).splitlines() if re.match(r'^[^#\s]', l)] if p.exists() else []


def sh(*args, cwd=None):
    try:
        r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, encoding='utf-8', errors='replace')
    except FileNotFoundError:
        return 127, ''
    return r.returncode, r.stdout.strip()


def git(repo, *args):
    return sh('git', '-C', str(repo), *args)


def raiz_por_omision():
    r = os.environ.get('MEMORIA_RAIZ')
    if r:
        m = re.match(r'^/([a-zA-Z])/(.*)$', r) if WIN else None   # formato de Git Bash: /c/Github
        return Path(f'{m[1].upper()}:/{m[2]}') if m else Path(r)
    return Path('C:/Github') if WIN else HOME / 'Github'


def carpeta_claude(ruta):
    """Carpeta de ~/.claude/projects de una ruta: todo lo que no es letra o número pasa a '-'
    (C:\\Github\\X-3.5 -> C--Github-X-3-5; /home/usuario/Github/x -> -home-usuario-Github-x)."""
    return CLAUDE / 'projects' / re.sub(r'[^a-zA-Z0-9]', '-', str(ruta))


def alias():
    return dict(m.groups() for l in lista('alias.txt') if (m := re.match(r'^\s*([^#=\s][^=]*?)\s*=\s*(\S+)\s*$', l)))


# ---------------------------------------------------------------------------------------------------- instalar

def destino_de(enlace):
    """Destino de un enlace (symlink o junction de Windows), o None si no es enlace."""
    try:
        t = os.readlink(enlace)
    except (OSError, ValueError):
        return None
    return t[4:] if t.startswith('\\\\?\\') else t


def crear_enlace(enlace, destino):
    """enlace -> destino (carpeta). Lo que hubiera en su lugar queda como <nombre>.respaldo-<fecha>. True si lo creó."""
    enlace.parent.mkdir(parents=True, exist_ok=True)
    t = destino_de(enlace)
    if t is not None:
        if os.path.normcase(os.path.abspath(t)) == os.path.normcase(str(destino)):
            return False
        os.rmdir(enlace) if WIN else os.unlink(enlace)   # quita solo el enlace, no su destino
    elif enlace.exists():
        if any(enlace.iterdir()):
            enlace.rename(enlace.with_name(f'{enlace.name}.respaldo-{FECHA}'))   # nunca se borra algo local
        else:
            enlace.rmdir()
    if WIN:   # junction: no pide permisos de administrador
        subprocess.run(['cmd', '/c', 'mklink', '/J', str(enlace), str(destino)], capture_output=True, check=True)
    else:
        enlace.symlink_to(destino, target_is_directory=True)
    return True


def enlazar(raiz, carpeta, destino):
    # La memoria automática de Claude escribe y carga ~/.claude/projects/<carpeta>/memory: se enlaza con la carpeta del
    # proyecto aquí, así lo que Claude anota cae en este repo y su índice se carga al abrir el repo.
    memoria = carpeta_claude(raiz / carpeta) / 'memory'
    if crear_enlace(memoria, destino):
        print(f'enlazado: {memoria.parent.name} -> {destino.name}')


def quitar_import(raiz, carpeta, proyecto):
    """Versiones anteriores del arnés importaban el índice desde el CLAUDE.md del repo; con la memoria automática el
    índice llegaba dos veces. El import sale: en CLAUDE.local.md se borra, en CLAUDE.md queda como texto."""
    repo = raiz / carpeta
    linea = f'@~/.claude/memoria-claude/{proyecto}/MEMORY.md'
    local = repo / 'CLAUDE.local.md'
    if local.exists() and linea in leer(local):
        resto = [l for l in leer(local).splitlines() if l != linea and not l.startswith('# Memoria del proyecto (la pone')]
        if any(l.strip() for l in resto):
            escribir(local, '\n'.join(resto) + '\n')
        else:
            local.unlink()
        print(f'{carpeta}/CLAUDE.local.md: sin import del índice')
    md = repo / 'CLAUDE.md'
    if not (md.exists() and linea in leer(md)):
        return
    if git(repo, 'status', '--porcelain', '--', 'CLAUDE.md')[1]:
        print(f'aviso: {carpeta}/CLAUDE.md tiene cambios sin commit de otra sesión: su import se quita en otra corrida')
        return
    texto = leer(md).replace('Este índice se carga en cada sesión:\n\n' + linea,
                             f'Su índice, `~/.claude/memoria-claude/{proyecto}/MEMORY.md`, lo carga la memoria '
                             f'automática de Claude.').replace(linea, f'`{linea[1:]}`')
    escribir(md, texto)
    git(repo, 'commit', '-q', '-m', 'chore: el índice de memoria lo carga la memoria automática de Claude', '--',
        'CLAUDE.md')
    pendientes = git(repo, 'log', '--oneline', '@{u}..')[1].splitlines()
    if len(pendientes) != 1 or git(repo, 'push', '-q')[0]:
        print(f'aviso: {carpeta}: el cambio de CLAUDE.md quedó en un commit local sin subir')
    print(f'{carpeta}/CLAUDE.md: import del índice cambiado por texto')


def conectar(raiz, carpeta, proyecto):
    if not (raiz / carpeta / '.git').exists():
        return
    enlazar(raiz, carpeta, CENTRAL / proyecto)
    quitar_import(raiz, carpeta, proyecto)


def fusionar(destino, origen):
    """Agrega lo que falte sin pisar valores del equipo. En listas (hooks) agrega los elementos que no estén y quita
    los del arnés que ya no estén en la configuración, así una actualización cambia un hook en vez de duplicarlo."""
    cambios = 0
    for k, o in origen.items():
        d = destino.get(k)
        if k not in destino:
            destino[k] = o
            cambios += 1
        elif isinstance(d, dict) and isinstance(o, dict):
            cambios += fusionar(d, o)
        elif isinstance(d, list) and isinstance(o, list):
            clave = lambda x: json.dumps(x, sort_keys=True, ensure_ascii=False)
            nuevos = {clave(x) for x in o}
            quedan = [x for x in d if not (MARCA in clave(x) and clave(x) not in nuevos)]
            ya = {clave(x) for x in quedan}
            faltan = [x for x in o if clave(x) not in ya]
            if faltan or len(quedan) != len(d):
                destino[k] = quedan + faltan
                cambios += len(faltan) + len(d) - len(quedan)
    return cambios


def nube():
    """Carpeta de OneDrive del equipo, o None."""
    for c in (os.environ.get('MEMORIA_NUBE'), os.environ.get('OneDrive'), HOME / 'OneDrive',
              *sorted((HOME / 'Library' / 'CloudStorage').glob('OneDrive*'))):
        if c and Path(c).is_dir():
            return Path(c)
    return None


def config_arnes(raiz):
    origen = json.loads(leer(CENTRAL / 'config' / 'settings-memoria.json'))
    env = origen.setdefault('env', {})
    for x in lista('apagadas.txt'):   # plugin:<nombre> apagado (caveman, ponytail…): no se agrega
        if x.startswith('plugin:'):
            p = x[len('plugin:'):]
            for k in [k for k in origen.get('enabledPlugins', {}) if k.split('@')[0] == p]:
                del origen['enabledPlugins'][k]
            origen.get('extraKnownMarketplaces', {}).pop(p, None)
            for k in [k for k in env if k.startswith(p.upper() + '_')]:
                del env[k]
    if raiz != (Path('C:/Github') if WIN else HOME / 'Github'):
        env['MEMORIA_RAIZ'] = str(raiz)                     # los hooks buscan los repos ahí
    n = nube()
    if n and not (WIN and os.environ.get('OneDrive')):
        env['MEMORIA_NUBE'] = str(n)                        # en Mac la carpeta de OneDrive no tiene variable propia
    return origen


def configurar(raiz):
    origen = config_arnes(raiz)
    settings = CLAUDE / 'settings.json'
    if not settings.exists():
        escribir_json(settings, origen)
        print('creado ~/.claude/settings.json')
        return
    datos = json.loads(leer(settings))
    if fusionar(datos, origen):
        shutil.copy(settings, f'{settings}.respaldo-{FECHA}')
        escribir_json(settings, datos)
        print(f'fusionado config/settings-memoria.json en ~/.claude/settings.json (respaldo settings.json.respaldo-{FECHA})')


def llave():
    if os.environ.get('MEMORIA_LLAVE'):
        return Path(os.environ['MEMORIA_LLAVE'])
    if WIN and os.environ.get('OneDrive'):
        return Path(os.environ['OneDrive']) / 'Almacén personal' / 'memoria-claude-llave.txt'
    return HOME / '.config' / 'memoria-claude' / 'llave-age.txt'


def buscar_age():
    a = shutil.which('age')
    if a or not WIN:
        return a
    paquetes = Path(os.environ.get('LOCALAPPDATA', HOME / 'AppData' / 'Local')) / 'Microsoft' / 'WinGet' / 'Packages'
    return next((str(p) for p in paquetes.glob('FiloSottile.age*/**/age.exe')), None)   # recién instalado, sin PATH


def instalar_age():
    if WIN:
        sh('winget', 'install', '--id', 'FiloSottile.age', '-e', '--silent', '--accept-source-agreements',
           '--accept-package-agreements')
    elif shutil.which('brew'):
        sh('brew', 'install', 'age')
    return buscar_age()


def descifrar():
    # secretos/archivos.txt: rutas relativas a la carpeta de usuario. Cada una viaja cifrada con la llave pública
    # (secretos/destinatario.txt); la privada vive fuera del repo (ver llave()).
    age = None
    for ruta in lista('secretos/archivos.txt'):
        destino = HOME / ruta
        cifrado = CENTRAL / 'secretos' / (re.sub(r'^\.', '', re.sub(r'[\\/]', '__', ruta)) + '.age')   # sin punto inicial
        if destino.exists() or not cifrado.exists():
            continue
        if not llave().exists():
            print(f'aviso: no se descifró {ruta}: falta la llave privada en {llave()} (o define MEMORIA_LLAVE)')
            continue
        age = age or buscar_age() or instalar_age()
        if not age:
            print('aviso: falta age para descifrar los secretos (https://github.com/FiloSottile/age)')
            return
        destino.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run([age, '-d', '-i', str(llave()), '-o', str(destino), str(cifrado)])
        print(f'descifrado: {ruta}')


def instalar_resto():
    for s in sorted((CENTRAL / 'skills').glob('*/SKILL.md')):   # atajos del arnés: /retomar, /cerrar-tema, /memorias…
        if crear_enlace(CLAUDE / 'skills' / s.parent.name, s.parent):
            print(f'atajo instalado: /{s.parent.name}')
    n = nube()
    if n:
        (n / 'respaldos').mkdir(exist_ok=True)   # lo llena hooks/sesion-fin.sh
    precommit = CENTRAL / '.git' / 'hooks' / 'pre-commit'
    if not precommit.exists():
        escribir(precommit, '#!/usr/bin/env bash\nexec bash "$(git rev-parse --show-toplevel)/hooks/pre-commit.sh"\n')
        precommit.chmod(0o755)
        print('instalado el candado de secretos (pre-commit)')
    usuario = CLAUDE / 'CLAUDE.md'
    imp = '@~/.claude/memoria-claude/CLAUDE.md'
    previo = leer(usuario) if usuario.exists() else ''
    if imp not in previo:
        escribir(usuario, previo + ('' if not previo or previo.endswith('\n') else '\n') + imp + '\n')
        print(f'agregado a ~/.claude/CLAUDE.md: {imp}')


def proyectos(solo=''):
    return sorted((c for c in CENTRAL.iterdir() if c.is_dir() and not c.name.startswith('.')
                   and c.name not in NO_PROYECTO and (not solo or c.name == solo)), key=lambda c: c.name.lower())


def instalar(raiz, solo=''):
    carpetas = proyectos(solo)
    if not solo:   # repos.txt: <carpeta> <url>, de dónde clonar cada repo en un equipo nuevo
        repos_txt = CENTRAL / 'repos.txt'
        urls = dict(re.match(r'^(\S+)\s+(\S+)$', l).groups() for l in lista('repos.txt') if re.match(r'^\S+\s+\S+$', l))
        for c in carpetas:
            repo = raiz / c.name
            if (repo / '.git').exists():
                urls[c.name] = git(repo, 'remote', 'get-url', 'origin')[1]
            elif urls.get(c.name):
                os.environ['GIT_TERMINAL_PROMPT'] = '0'   # sin permiso, que falle en vez de quedarse esperando
                if sh('git', 'clone', '-q', urls[c.name], str(repo))[0]:
                    print(f'aviso: no se pudo clonar {c.name} ({urls[c.name]}): revisa gh auth login y el acceso')
                else:
                    print(f'clonado: {c.name}')
        nuevo = ''.join(f'{c.name} {urls[c.name]}\n' for c in carpetas if urls.get(c.name))   # sin carpeta, fuera
        if (leer(repos_txt) if repos_txt.exists() else '') != nuevo:
            escribir(repos_txt, nuevo)

    for c in carpetas:
        conectar(raiz, c.name, c.name)
    for carpeta, proyecto in alias().items():
        if solo and carpeta != solo:
            continue
        if (CENTRAL / proyecto).is_dir():
            conectar(raiz, carpeta, proyecto)
        else:
            print(f"aviso: alias.txt: no existe la carpeta de proyecto '{proyecto}'")
    if solo:
        return
    apagar()
    configurar(raiz)
    descifrar()
    instalar_resto()


def apagar():
    """Notas de apagadas.txt (preferencias o prácticas que no quieres): fuera de compartidas/ y de su índice."""
    indice = CENTRAL / 'compartidas' / 'MEMORY.md'
    for x in lista('apagadas.txt'):
        if x.startswith('plugin:'):
            continue
        n = Path(x).stem
        (CENTRAL / 'compartidas' / f'{n}.md').unlink(missing_ok=True)
        if indice.exists() and f'({n}.md)' in leer(indice):
            escribir(indice, ''.join(l + '\n' for l in leer(indice).splitlines() if f'({n}.md)' not in l))
            print(f'apagada: {n}')


# ----------------------------------------------------------------------------------------------------- retomar

def texto_de(d):
    """Texto legible de una entrada user/assistant de la transcripción (sin resultados de herramientas)."""
    c = d.get('message', {}).get('content')
    if isinstance(c, str):
        return c
    partes = []
    for b in c or []:
        if b.get('type') == 'text':
            partes.append(b['text'])
        elif b.get('type') == 'tool_use' and b.get('name') == 'AskUserQuestion':
            partes.append('[preguntó] ' + ' / '.join(q.get('question', '') for q in b.get('input', {}).get('questions', [])))
    return '\n'.join(partes)


def entradas(t, cola=400_000):
    """Entradas user/assistant del final de una transcripción .jsonl (solo la cola: las hay de decenas de MB)."""
    with open(t, 'rb') as f:
        f.seek(0, 2)
        inicio = max(0, f.tell() - cola)
        f.seek(inicio)
        lineas = f.read().decode('utf-8', 'replace').splitlines()[1 if inicio else 0:]   # la primera puede ir partida
    out = []
    for l in lineas:
        try:
            d = json.loads(l)
        except ValueError:
            continue
        if d.get('type') in ('user', 'assistant'):
            out.append(d)
    return out


def cortada(es):
    """La sesión terminó en el error de límite de uso (nadie escribió después)."""
    ult = next((d for d in reversed(es) if not d.get('isMeta')), None)
    return bool(ult and ult.get('type') == 'assistant' and ult.get('isApiErrorMessage') and ult.get('error') == 'rate_limit')


def resumen(t, es):
    ult = es[-1] if es else {}
    usuario = [x for d in es if d.get('type') == 'user' and not d.get('isMeta') and (x := texto_de(d).strip())
               and not x.startswith('<')][-4:]
    claude = [x for d in es if d.get('type') == 'assistant' and not d.get('isApiErrorMessage') and (x := texto_de(d).strip())][-2:]
    hora = datetime.datetime.fromtimestamp(t.stat().st_mtime).strftime('%Y-%m-%d %H:%M')
    corte = texto_de(ult).strip() if cortada(es) else 'no se cortó por límite'
    lineas = [f'Sesión {t.stem} ({hora}, carpeta de trabajo {ult.get("cwd", "?")}, rama {ult.get("gitBranch", "?")}): {corte}.',
              'Últimos mensajes del usuario:'] + [f'  - {x[:400]}' for x in usuario] + \
             ['Últimas respuestas de Claude:'] + [f'  - {x[:600]}' for x in claude] + \
             [f'Transcripción completa: {t}']
    return '\n'.join(lineas)


def retomar(ident='', auto=False, cwd='', sesion=''):
    base = CLAUDE / 'projects'
    hechas_txt = CLAUDE / 'memoria-claude-retomadas.txt'   # local: cortes ya avisados en un chat nuevo
    hechas = set(leer(hechas_txt).split()) if hechas_txt.exists() else set()
    if ident:
        candidatas = sorted(base.glob(f'*/{ident}*.jsonl'))
    elif auto:   # solo las de la misma carpeta de trabajo, de las últimas 48 horas
        candidatas = [t for t in carpeta_claude(cwd).glob('*.jsonl') if t.stem != sesion and t.stem not in hechas
                      and time.time() - t.stat().st_mtime < 48 * 3600]
    else:        # a mano: cualquier carpeta, últimos 7 días
        candidatas = [t for t in base.glob('*/*.jsonl') if time.time() - t.stat().st_mtime < 7 * 86400]
    candidatas.sort(key=lambda t: t.stat().st_mtime, reverse=True)
    elegidas = []
    for t in candidatas:
        es = entradas(t)
        if ident or cortada(es):
            elegidas.append((t, es))
        if len(elegidas) == 3:
            break
    if not elegidas:
        if not auto:
            print('No hay sesiones cortadas por límite de uso en los últimos 7 días.' if not ident else f'No encontré la sesión {ident}.')
        return
    if auto:
        escribir(hechas_txt, ''.join(f'{x}\n' for x in sorted(hechas | {t.stem for t, _ in elegidas})))
    print('Retomar: ' + ('hay sesiones de este proyecto que se cortaron por límite de uso (cambio de cuenta). '
                         if len(elegidas) > 1 or not ident else '')
          + 'Antes de responder, lee el bloque EN CURSO de la nota principal del proyecto y el final de la sesión que '
            'corresponda; retoma desde ahí sin volver a preguntar lo decidido. Si hay más de una, pregunta cuál sigue.')
    for t, es in elegidas:
        print('\n' + resumen(t, es))


# ----------------------------------------------------------------------------------------------- revisar / doctor

def indices_grandes(extra=()):
    """Índices que se cargan en cada chat y pasan del presupuesto (tamaño o líneas largas)."""
    out = []
    for p in [CENTRAL / 'compartidas' / 'MEMORY.md', *extra]:
        if not p.exists():
            continue
        b = len(p.read_bytes())
        largas = sum(len(l) > LINEA_MAX for l in leer(p).splitlines())
        if b > PRESUPUESTO:
            out.append(f'{p.relative_to(CENTRAL).as_posix()} ({b / 1024:.1f} KB, {largas} líneas de más de {LINEA_MAX})')
    return out


def version_nueva():
    if git(CENTRAL, 'remote', 'get-url', 'plantilla')[0]:
        return None   # solo copias hechas de la plantilla
    local = leer(CENTRAL / 'VERSION').strip() if (CENTRAL / 'VERSION').exists() else '0'
    os.environ['GIT_TERMINAL_PROMPT'] = '0'
    tags = re.findall(r'refs/tags/v([\d.]+)$', git(CENTRAL, 'ls-remote', '--tags', '--refs', 'plantilla')[1], re.M)
    n = lambda v: tuple(int(x) for x in v.split('.'))
    ultima = max(tags, key=n, default=None)
    return ultima if ultima and n(ultima) > n(local) else None


def revisar(cwd, sesion):
    """Lo que el hook de inicio le pasa a Claude: sesiones cortadas que retomar y, una vez al día por equipo, avisos."""
    retomar(auto=True, cwd=cwd, sesion=sesion)
    sello = CLAUDE / 'memoria-claude-revisado.txt'
    hoy = datetime.date.today().isoformat()
    if sello.exists() and leer(sello).strip() == hoy:
        return
    escribir(sello, hoy + '\n')
    avisos = []
    top = git(cwd, 'rev-parse', '--show-toplevel')[1] if cwd else ''
    p = alias().get(Path(top).name, Path(top).name) if top else ''
    grandes = indices_grandes([CENTRAL / p / 'MEMORY.md'] if p else [])
    if grandes:
        avisos.append('memoria-claude: índices que se cargan en cada chat y pasan del presupuesto (4 KB, líneas de '
                      f'{LINEA_MAX} caracteres): {", ".join(grandes)}. Propón compactarlos (una línea corta por nota, '
                      'el detalle en la nota).')
    v = version_nueva()
    if v:
        avisos.append(f'memoria-claude: hay versión nueva del arnés (v{v}). Avísale al usuario en una línea que puede '
                      'decir "actualiza el arnés" para ver las novedades y aplicarlas.')
    if avisos:
        print(' | '.join(avisos))


# -------------------------------------------------------------------------------------------------- actualizar

PLANTILLA = os.environ.get('MEMORIA_PLANTILLA', 'https://github.com/yolovany/memoria-claude-plantilla.git')
PROPIOS = {'CLAUDE.md', 'VERSION', 'repos.txt', 'alias.txt', 'respaldos-extra.txt', 'apagadas.txt', '.gitignore',
           'secretos/archivos.txt', 'secretos/destinatario.txt', 'compartidas/MEMORY.md'}   # nunca los toca actualizar


def lf(b):
    return b.replace(b'\r\n', b'\n')   # con core.autocrlf los archivos locales pueden tener CRLF


def en_version(tag, ruta):
    r = subprocess.run(['git', '-C', str(CENTRAL), 'show', f'{tag}:{ruta}'], capture_output=True)
    return r.stdout if r.returncode == 0 else None


def archivos_de(tag):
    return set(git(CENTRAL, 'ls-tree', '-r', '--name-only', tag)[1].splitlines())


def manifiesto(tag):
    """Rutas del arnés en esa versión (arnes.txt: una por línea; una carpeta con / al final abarca todo lo suyo)."""
    lineas = [l.strip() for l in (en_version(tag, 'arnes.txt') or b'').decode('utf-8').splitlines()
              if l.strip() and not l.startswith('#')]
    todos = archivos_de(tag)
    return {a for a in todos for l in lineas if a == l or (l.endswith('/') and a.startswith(l))}


def nota(ruta):
    return Path(ruta).stem


def indice_nuevo(tag, apagadas, arnes_notas):
    """compartidas/MEMORY.md: las líneas del arnés de la versión nueva (menos las apagadas) y luego las propias."""
    link = lambda l: (m := re.search(r'\]\(([^)]+\.md)\)', l)) and nota(m[1])
    nuevo = [l for l in (en_version(tag, 'compartidas/MEMORY.md') or b'').decode('utf-8').splitlines()
             if not (link(l) and link(l) in apagadas)]
    local = CENTRAL / 'compartidas' / 'MEMORY.md'
    propias = [l for l in (leer(local).splitlines() if local.exists() else []) if link(l) and link(l) not in arnes_notas]
    if propias:
        nuevo += ['', '## Propias', *propias]
    return '\n'.join(nuevo).rstrip('\n') + '\n'


def actualizar(aplicar=False, forzar=(), version=''):
    """Trae de la plantilla pública lo del arnés (arnes.txt) sin tocar lo propio: lo que no editaste se reemplaza, lo que
    editaste se lista para decidir (--forzar RUTA lo reemplaza), lo de apagadas.txt no llega."""
    os.environ['GIT_TERMINAL_PROMPT'] = '0'
    if git(CENTRAL, 'remote', 'get-url', 'plantilla')[0]:
        git(CENTRAL, 'remote', 'add', 'plantilla', PLANTILLA)
        print(f'remoto plantilla agregado: {PLANTILLA}')
    if git(CENTRAL, 'fetch', '-q', '--tags', '--force', 'plantilla')[0]:
        print('aviso: no se pudo traer la plantilla (¿sin red?)')
        return
    n = lambda v: tuple(int(x) for x in v.lstrip('v').split('.'))
    tags = sorted(re.findall(r'^v[\d.]+$', git(CENTRAL, 'tag', '--list', 'v*')[1], re.M), key=n)
    nueva = version or (tags[-1] if tags else '')
    if not nueva:
        print('aviso: la plantilla no tiene versiones publicadas')
        return
    local_v = leer(CENTRAL / 'VERSION').strip() if (CENTRAL / 'VERSION').exists() else ''
    if local_v and f'v{local_v}' in tags:
        base = f'v{local_v}'
    else:   # copia vieja sin VERSION: la versión de la que salió es la que más archivos comparte con ella
        igual = lambda t: sum(1 for a in archivos_de(t) if (CENTRAL / a).is_file()
                              and lf((CENTRAL / a).read_bytes()) == lf(en_version(t, a) or b''))
        base = max(tags, key=lambda t: (igual(t), n(t)))
        print(f'copia sin VERSION: salió de {base} (la que más archivos comparte)')
    if base == nueva and not forzar:
        print(f'ya está en {nueva}')
        return
    apagadas = {nota(l) if l.endswith('.md') else l for l in lista('apagadas.txt')}
    arnes_nuevo, arnes_base = manifiesto(nueva), (manifiesto(base) or archivos_de(base))
    arnes_notas = {nota(a) for a in arnes_nuevo | arnes_base if a.startswith('compartidas/')}
    plan = {'agregar': [], 'actualizar': [], 'quitar': [], 'editado': [], 'apagado': [], 'borrado por ti': []}
    for a in sorted(arnes_nuevo):
        if a == 'compartidas/MEMORY.md':
            continue
        if a.startswith('compartidas/') and nota(a) in apagadas:
            plan['apagado'].append(a)
            continue
        p, nuevo, previo = CENTRAL / a, lf(en_version(nueva, a)), en_version(base, a)
        if not p.exists():
            plan['borrado por ti' if previo is not None and a in arnes_base else 'agregar'].append(a)
        elif lf(p.read_bytes()) == nuevo:
            continue
        elif (previo is not None and lf(p.read_bytes()) == lf(previo)) or a in forzar:
            plan['actualizar'].append(a)
        else:
            plan['editado'].append(a)
    for a in sorted(arnes_base - arnes_nuevo - PROPIOS):   # salió del arnés: se quita si no lo editaste
        p, previo = CENTRAL / a, en_version(base, a)
        if p.is_file() and previo is not None and lf(p.read_bytes()) == lf(previo):
            plan['quitar'].append(a)
    print(f'Actualizar el arnés: {base} -> {nueva}')
    novedades = (en_version(nueva, 'NOVEDADES.md') or b'').decode('utf-8')
    for bloque in re.split(r'(?m)^(?=## v)', novedades):
        m = re.match(r'## (v[\d.]+)', bloque)
        if m and n(m[1]) > n(base):
            print(bloque.rstrip())
    for k, v in plan.items():
        if v:
            print(f'{k}: {", ".join(v)}')
    if plan['editado']:
        print('Los editados son tuyos: compáralos (git diff --no-index <archivo> con git show '
              f'{nueva}:<archivo>) y, si quieres la versión nueva, repite con --forzar <archivo>.')
    if not aplicar:
        print('(vista previa: nada cambió; para aplicarlo: python arnes.py actualizar --aplicar)')
        return
    for a in plan['agregar'] + plan['actualizar']:
        (CENTRAL / a).parent.mkdir(parents=True, exist_ok=True)
        (CENTRAL / a).write_bytes(lf(en_version(nueva, a)))
        if a.endswith(('.sh', '.py')):
            (CENTRAL / a).chmod(0o755)
    for a in plan['quitar']:
        (CENTRAL / a).unlink()
    escribir(CENTRAL / 'compartidas' / 'MEMORY.md', indice_nuevo(nueva, apagadas, arnes_notas))
    escribir(CENTRAL / 'VERSION', nueva.lstrip('v') + '\n')
    apagar()
    configurar(raiz_por_omision())
    instalar_resto()
    cambiados = sorted({*plan['agregar'], *plan['actualizar'], *plan['quitar'], 'compartidas', 'VERSION'})
    git(CENTRAL, 'add', '-A', '--', *cambiados)
    git(CENTRAL, 'commit', '-q', '-m', f'arnés: actualizado a {nueva}', '--', *cambiados)
    print(f'listo: arnés en {nueva} (commit hecho; lo sube el hook de cierre)')


def tokens(b):
    return round(b / 3.5)   # ~3.5 bytes por token en español


def doctor(raiz):
    ok = lambda bueno, texto, arreglo='': print(('  ✓ ' if bueno else '  ✗ ') + texto + ('' if bueno or not arreglo else f'  → {arreglo}'))
    print('Programas')
    ok(bool(shutil.which('git')), 'git', 'instala Git (en Windows, Git para Windows)')
    ok(sh('gh', 'auth', 'status')[0] == 0, 'gh con sesión', 'gh auth login')
    ok(sys.version_info >= (3, 8), f'Python {sys.version.split()[0]}')
    if lista('secretos/archivos.txt'):
        ok(bool(buscar_age()), 'age (secretos cifrados)', 'python arnes.py instalar lo instala, o https://github.com/FiloSottile/age')
        ok(llave().exists(), f'llave privada de age en {llave()}', 'restáurala de tu respaldo o define MEMORIA_LLAVE')
    print('Memoria')
    ok(git(CENTRAL, 'remote', 'get-url', 'origin')[0] == 0, 'remoto origin', 'git remote add origin <tu repo privado>')
    pendientes = git(CENTRAL, 'log', '--oneline', '@{u}..')[1]
    ok(not pendientes, 'todo subido', 'sin red o con choque: git -C ~/.claude/memoria-claude pull --rebase && git push')
    avisos = CLAUDE / 'memoria-claude-avisos.log'
    ok(not (avisos.exists() and avisos.stat().st_size), 'sin avisos pendientes', f'lee {avisos}')
    ok((CENTRAL / '.git' / 'hooks' / 'pre-commit').exists(), 'candado de secretos', 'python arnes.py instalar')
    usuario = CLAUDE / 'CLAUDE.md'
    ok(usuario.exists() and '@~/.claude/memoria-claude/CLAUDE.md' in leer(usuario), '~/.claude/CLAUDE.md carga la memoria', 'python arnes.py instalar')
    settings = CLAUDE / 'settings.json'
    faltan = fusionar(json.loads(leer(settings)), config_arnes(raiz)) if settings.exists() else 1
    ok(not faltan, 'hooks y ajustes en ~/.claude/settings.json', 'python arnes.py instalar')
    sin = [c.name for c in proyectos() if (raiz / c.name / '.git').exists()
           and destino_de(carpeta_claude(raiz / c.name) / 'memory') is None]
    ok(not sin, 'carpetas de memoria enlazadas', f'python arnes.py instalar (faltan: {", ".join(sin)})')
    print('Tokens que se cargan al abrir cada chat')
    fijos = [CLAUDE / 'CLAUDE.md', CENTRAL / 'CLAUDE.md', CENTRAL / 'REGLAS.md', CENTRAL / 'compartidas' / 'MEMORY.md']
    total = sum(len(p.read_bytes()) for p in fijos if p.exists())
    print(f'  siempre: ~{tokens(total)} tokens (~/.claude/CLAUDE.md, CLAUDE.md, REGLAS.md, compartidas/MEMORY.md)')
    for c in proyectos():
        m = c / 'MEMORY.md'
        if m.exists() and len(m.read_bytes()) > 200:
            print(f'  + {c.name}: ~{tokens(len(m.read_bytes()))} tokens')
    for g in indices_grandes([c / 'MEMORY.md' for c in proyectos()]):
        ok(False, f'índice grande: {g}', 'pídele a Claude "compacta ese índice"')
    print('  (además los plugins y el propio Claude Code; /context muestra el detalle en un chat)')


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    ap = argparse.ArgumentParser(description='Arnés de memoria-claude')
    ap.add_argument('orden', choices=['instalar', 'conectar', 'retomar', 'revisar', 'doctor', 'actualizar'])
    ap.add_argument('--aplicar', action='store_true', help='actualizar: aplicar (sin esto, solo vista previa)')
    ap.add_argument('--forzar', action='append', default=[], help='actualizar: reemplazar este archivo editado')
    ap.add_argument('--version', default='', help='actualizar: a esta versión (vX.Y.Z) en vez de la última')
    ap.add_argument('carpeta', nargs='?', help='conectar: la carpeta del repo; retomar: el id de la sesión')
    ap.add_argument('--raiz', type=Path, default=raiz_por_omision())
    ap.add_argument('--cwd', default='', help='revisar: carpeta de trabajo de la sesión')
    ap.add_argument('--sesion', default='', help='revisar: id de la sesión que abre')
    a = ap.parse_args()
    if a.orden == 'instalar':
        instalar(a.raiz)
    elif a.orden == 'conectar':
        if not a.carpeta:
            ap.error('conectar necesita la carpeta del repo')
        instalar(a.raiz, a.carpeta)
    elif a.orden == 'retomar':
        retomar(a.carpeta or '')
    elif a.orden == 'revisar':
        revisar(a.cwd, a.sesion)
    elif a.orden == 'actualizar':
        actualizar(a.aplicar, a.forzar, a.version)
    else:
        doctor(a.raiz)


if __name__ == '__main__':
    main()
