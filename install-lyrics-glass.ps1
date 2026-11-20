# Lyrics Glass - one-shot installer for Spotify (Windows, via Spicetify)
$ErrorActionPreference = 'Stop'
Write-Host "`n==> Lyrics Glass installer" -ForegroundColor Magenta

# 1. Install Spicetify CLI if missing
$env:Path += ";$env:LOCALAPPDATA\spicetify"
if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Spicetify..." -ForegroundColor Cyan
    Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" | Invoke-Expression
    $env:Path += ";$env:LOCALAPPDATA\spicetify"
}

# 2. Write the extension into Spicetify's Extensions folder
$extDir = Join-Path $env:APPDATA "spicetify\Extensions"
New-Item -ItemType Directory -Force -Path $extDir | Out-Null
$js = @'
// NAME: Lyrics Glass
// AUTHOR: you
// DESCRIPTION: Floating oil-on-glass lyrics window with glowing, animated, synced lyrics.
// Toggle: topbar button or Alt+L. Drag the header to move, drag the bottom-right corner to resize.

(function LyricsGlass() {
  const S = window.Spicetify;
  if (!S || !S.Player || !S.Platform || !S.CosmosAsync || !S.Topbar || !S.Topbar.Button) {
    setTimeout(LyricsGlass, 300);
    return;
  }

  /* ---------- styles ---------- */
  const css = `
  #lg-root{
    --lg-a:#ff8ad8; --lg-b:#7aa2ff;
    position:fixed; right:28px; bottom:110px; width:430px; height:560px;
    min-width:300px; min-height:260px; max-width:92vw; max-height:88vh;
    z-index:9999; overflow:hidden; resize:both; border-radius:28px;
    color:#fff; font-family:"Segoe UI Variable Display","Segoe UI",system-ui,sans-serif;
    background:
      radial-gradient(120% 90% at 0% 0%, rgba(255,255,255,.20), rgba(255,255,255,0) 55%),
      linear-gradient(145deg, rgba(255,255,255,.10), rgba(255,255,255,.03));
    -webkit-backdrop-filter: blur(30px) saturate(200%) brightness(1.08);
    backdrop-filter: blur(30px) saturate(200%) brightness(1.08);
    border:1px solid rgba(255,255,255,.22);
    box-shadow: 0 30px 80px rgba(0,0,0,.45), 0 0 60px -10px var(--lg-a),
                inset 0 1px 0 rgba(255,255,255,.55), inset 0 0 50px rgba(255,255,255,.05);
    transition: opacity .35s ease, transform .35s cubic-bezier(.2,.8,.2,1);
  }
  #lg-root.lg-hidden{opacity:0; transform:translateY(16px) scale(.97); pointer-events:none}
  #lg-root::after{ /* specular rim */
    content:""; position:absolute; inset:0; border-radius:inherit; pointer-events:none;
    background:linear-gradient(120deg, rgba(255,255,255,.35), transparent 28%, transparent 72%, rgba(255,255,255,.18));
    -webkit-mask:linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
    -webkit-mask-composite:xor; mask-composite:exclude; padding:1.5px;
  }
  /* oil-slick film */
  .lg-sheen{position:absolute; inset:-60%; pointer-events:none; mix-blend-mode:soft-light; opacity:.95;
    background:conic-gradient(from 0deg,#ff6ad5aa,#ffd86aaa,#6affc8aa,#6a9cffaa,#c26affaa,#ff6ad5aa);
    filter:blur(70px); animation:lg-spin 26s linear infinite}
  .lg-blob{position:absolute; width:260px; height:260px; border-radius:50%; filter:blur(55px);
    pointer-events:none; opacity:.55; mix-blend-mode:screen}
  .lg-blob.b1{background:var(--lg-a); left:-60px; top:-40px; animation:lg-drift1 14s ease-in-out infinite alternate}
  .lg-blob.b2{background:var(--lg-b); right:-80px; bottom:-60px; animation:lg-drift2 17s ease-in-out infinite alternate}
  @keyframes lg-spin{to{transform:rotate(360deg)}}
  @keyframes lg-drift1{to{transform:translate(180px,260px) scale(1.25)}}
  @keyframes lg-drift2{to{transform:translate(-200px,-240px) scale(.85)}}

  .lg-head{position:relative; z-index:2; display:flex; align-items:center; gap:12px;
    padding:16px 18px 10px 22px; cursor:grab; user-select:none}
  .lg-head:active{cursor:grabbing}
  .lg-meta{flex:1; min-width:0; display:flex; flex-direction:column; gap:2px}
  .lg-title{font-weight:650; font-size:15px; letter-spacing:.01em; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    text-shadow:0 0 14px var(--lg-a)}
  .lg-artist{font-size:12.5px; opacity:.65; white-space:nowrap; overflow:hidden; text-overflow:ellipsis}
  .lg-close{all:unset; cursor:pointer; width:28px; height:28px; border-radius:50%; display:grid; place-items:center;
    background:rgba(255,255,255,.12); font-size:16px; line-height:1; transition:background .2s, box-shadow .2s}
  .lg-close:hover{background:rgba(255,255,255,.25); box-shadow:0 0 16px var(--lg-a)}

  .lg-scroll{position:absolute; z-index:1; inset:58px 0 0 0; overflow-y:auto; scrollbar-width:none;
    -webkit-mask-image:linear-gradient(transparent 0, #000 14%, #000 82%, transparent 100%);
    mask-image:linear-gradient(transparent 0, #000 14%, #000 82%, transparent 100%)}
  .lg-scroll::-webkit-scrollbar{display:none}
  .lg-lines{padding:0 26px}

  .lg-line{
    --d:3; --p:0%;
    margin:6px 0; padding:6px 2px; font-size:25px; line-height:1.28; font-weight:700; letter-spacing:-.01em;
    color:rgba(255,255,255,.92); cursor:pointer; transform-origin:left center;
    opacity:max(.2, calc(1 - var(--d) * .2));
    filter:blur(min(calc(var(--d) * .7px), 3px));
    transform:scale(.94);
    transition:opacity .5s ease, filter .5s ease, transform .55s cubic-bezier(.2,.8,.2,1);
    overflow-wrap:anywhere;
  }
  .lg-line:hover{opacity:.85; filter:none}
  .lg-line.on{
    opacity:1; filter:drop-shadow(0 0 5px rgba(255,255,255,.55)) drop-shadow(0 0 18px var(--lg-a)) drop-shadow(0 0 38px var(--lg-b));
    transform:scale(1.04);
    background:linear-gradient(90deg,#fff 0,#fff var(--p),rgba(255,255,255,.34) calc(var(--p) + 1.5%));
    -webkit-background-clip:text; background-clip:text; -webkit-text-fill-color:transparent; color:transparent;
  }
  .lg-line.plain{opacity:.9; filter:none; transform:none; cursor:default; font-size:20px; font-weight:600}
  .lg-empty{padding:40px 26px; font-size:18px; font-weight:600; opacity:.7; text-shadow:0 0 18px var(--lg-a)}

  @media (prefers-reduced-motion: reduce){
    .lg-sheen,.lg-blob{animation:none} .lg-line{transition:none}
  }`;
  const style = document.createElement("style");
  style.textContent = css;
  document.head.appendChild(style);

  /* ---------- DOM ---------- */
  const root = document.createElement("div");
  root.id = "lg-root";
  root.className = "lg-hidden";
  root.innerHTML = `
    <div class="lg-sheen"></div><div class="lg-blob b1"></div><div class="lg-blob b2"></div>
    <div class="lg-head">
      <div class="lg-meta"><span class="lg-title">Lyrics</span><span class="lg-artist"></span></div>
      <button class="lg-close" title="Close (Alt+L)">✕</button>
    </div>
    <div class="lg-scroll"><div class="lg-lines"></div></div>`;
  document.body.appendChild(root);

  const $ = (s) => root.querySelector(s);
  const head = $(".lg-head"), scroller = $(".lg-scroll"), linesEl = $(".lg-lines");
  const titleEl = $(".lg-title"), artistEl = $(".lg-artist");

  /* ---------- persisted position / size ---------- */
  const KEY = "lyrics-glass:layout";
  try {
    const l = JSON.parse(localStorage.getItem(KEY) || "null");
    if (l) {
      root.style.width = l.w + "px"; root.style.height = l.h + "px";
      if (l.x != null) { root.style.left = l.x + "px"; root.style.top = l.y + "px"; root.style.right = "auto"; root.style.bottom = "auto"; }
    }
  } catch (e) {}
  const saveLayout = () => {
    const r = root.getBoundingClientRect();
    try { localStorage.setItem(KEY, JSON.stringify({ x: r.left, y: r.top, w: r.width, h: r.height })); } catch (e) {}
  };

  head.addEventListener("mousedown", (e) => {
    if (e.target.closest(".lg-close")) return;
    const r = root.getBoundingClientRect();
    const dx = e.clientX - r.left, dy = e.clientY - r.top;
    root.style.right = root.style.bottom = "auto";
    const move = (ev) => {
      const x = Math.min(Math.max(0, ev.clientX - dx), innerWidth - 80);
      const y = Math.min(Math.max(0, ev.clientY - dy), innerHeight - 60);
      root.style.left = x + "px"; root.style.top = y + "px";
    };
    const up = () => { removeEventListener("mousemove", move); removeEventListener("mouseup", up); saveLayout(); };
    addEventListener("mousemove", move); addEventListener("mouseup", up);
    e.preventDefault();
  });
  root.addEventListener("mouseup", saveLayout);

  /* ---------- state ---------- */
  let open = false, raf = 0, lines = [], els = [], synced = false, active = -2, token = 0;

  /* ---------- helpers ---------- */
  const trackInfo = () => {
    const it = (S.Player.data && S.Player.data.item) || {};
    const md = it.metadata || {};
    return {
      uri: it.uri || "",
      name: it.name || md.title || "",
      artist: (it.artists && it.artists[0] && it.artists[0].name) || md.artist_name || "",
      album: (it.album && it.album.name) || md.album_title || "",
      duration: (it.duration && it.duration.milliseconds) || Number(md.duration) || 0,
    };
  };

  function parseLRC(text) {
    const out = [];
    text.split("\n").forEach((raw) => {
      const stamps = [...raw.matchAll(/\[(\d+):(\d+(?:\.\d+)?)\]/g)];
      if (!stamps.length) return;
      const words = raw.replace(/\[[^\]]*\]/g, "").trim();
      stamps.forEach((m) => out.push({ t: (Number(m[1]) * 60 + Number(m[2])) * 1000, text: words }));
    });
    return out.sort((a, b) => a.t - b.t);
  }

  async function fromSpotify(id) {
    const url = `https://spclient.wg.spotify.com/color-lyrics/v2/track/${id}?format=json&vocalRemoval=false&market=from_token`;
    const res = await S.CosmosAsync.get(url, null, { "app-platform": "WebPlayer" });
    const L = res && res.lyrics;
    if (!L || !L.lines || !L.lines.length) return null;
    const isSynced = L.syncType === "LINE_SYNCED";
    return { synced: isSynced, lines: L.lines.map((l) => ({ t: Number(l.startTimeMs) || 0, text: l.words })) };
  }

  async function fromLrclib(t) {
    const q = new URLSearchParams({ track_name: t.name, artist_name: t.artist, album_name: t.album, duration: Math.round(t.duration / 1000) });
    let r = await fetch("https://lrclib.net/api/get?" + q);
    if (!r.ok) {
      r = await fetch("https://lrclib.net/api/search?" + new URLSearchParams({ track_name: t.name, artist_name: t.artist }));
      if (!r.ok) return null;
      const arr = await r.json();
      const hit = arr.find((x) => x.syncedLyrics) || arr[0];
      return hit ? lrcToResult(hit) : null;
    }
    return lrcToResult(await r.json());
  }
  function lrcToResult(d) {
    if (d.syncedLyrics) return { synced: true, lines: parseLRC(d.syncedLyrics) };
    if (d.plainLyrics) return { synced: false, lines: d.plainLyrics.split("\n").map((x) => ({ t: 0, text: x })) };
    return null;
  }

  /* ---------- colors from album art ---------- */
  async function applyColors(uri) {
    let a = "#ff8ad8", b = "#7aa2ff";
    try {
      const c = await S.colorExtractor(uri);
      a = c.VIBRANT || c.PROD_VIBRANT || c.LIGHT_VIBRANT || a;
      b = c.DESATURATED || c.DARK_VIBRANT || c.VIBRANT_NON_ALARMING || b;
    } catch (e) {}
    root.style.setProperty("--lg-a", a);
    root.style.setProperty("--lg-b", b);
  }

  /* ---------- render ---------- */
  function showMessage(msg) {
    els = []; lines = []; active = -2;
    linesEl.innerHTML = `<div class="lg-empty">${msg}</div>`;
    linesEl.style.padding = "0 26px";
  }

  function render() {
    linesEl.innerHTML = "";
    els = lines.map((l, i) => {
      const d = document.createElement("div");
      d.className = "lg-line" + (synced ? "" : " plain");
      d.textContent = l.text || "♪";
      if (synced) d.addEventListener("click", () => S.Player.seek(l.t));
      linesEl.appendChild(d);
      return d;
    });
    active = -2;
    padLines();
    scroller.scrollTop = 0;
    if (synced) update(S.Player.getProgress());
  }

  function padLines() {
    if (!synced) { linesEl.style.padding = "8px 26px 40px"; return; }
    const h = Math.round(scroller.clientHeight / 2);
    linesEl.style.padding = `${h - 30}px 26px ${h}px`;
  }

  function center() {
    if (active < 0 || !els[active]) return;
    const el = els[active];
    const top = el.offsetTop - scroller.clientHeight / 2 + el.offsetHeight / 2;
    scroller.scrollTo({ top, behavior: "smooth" });
  }

  function update(pos) {
    if (!synced || !lines.length) return;
    let i = -1;
    while (i + 1 < lines.length && lines[i + 1].t <= pos + 120) i++;
    if (i !== active) {
      active = i;
      els.forEach((e, k) => {
        e.style.setProperty("--d", Math.abs(k - i));
        e.classList.toggle("on", k === i);
        if (k !== i) e.style.setProperty("--p", "0%");
      });
      center();
    }
    if (i >= 0 && els[i]) {
      const a = lines[i], nextT = lines[i + 1] ? lines[i + 1].t : a.t + 4000;
      const dur = Math.max(400, Math.min(nextT - a.t, 7000));
      const p = Math.min(100, Math.max(0, ((pos - a.t) / dur) * 100));
      els[i].style.setProperty("--p", p.toFixed(1) + "%");
    }
  }

  function tick() {
    if (!open) return;
    update(S.Player.getProgress());
    raf = requestAnimationFrame(tick);
  }

  /* ---------- load lyrics for current track ---------- */
  async function load() {
    const t = trackInfo();
    const my = ++token;
    titleEl.textContent = t.name || "Lyrics";
    artistEl.textContent = t.artist;
    if (!t.uri) return showMessage("Play a song to see lyrics.");
    applyColors(t.uri);
    showMessage("Finding lyrics…");

    let result = null;
    try { if (t.uri.startsWith("spotify:track:")) result = await fromSpotify(t.uri.split(":")[2]); } catch (e) {}
    if (!result) { try { result = await fromLrclib(t); } catch (e) {} }
    if (my !== token) return; // song changed while loading

    if (!result || !result.lines.length) return showMessage("No lyrics found for this track.");
    synced = result.synced;
    lines = result.lines;
    render();
  }

  /* ---------- open / close ---------- */
  function setOpen(v) {
    open = v;
    root.classList.toggle("lg-hidden", !v);
    cancelAnimationFrame(raf);
    if (v) { load(); raf = requestAnimationFrame(tick); }
  }
  const toggle = () => setOpen(!open);

  $(".lg-close").addEventListener("click", () => setOpen(false));
  addEventListener("keydown", (e) => { if (e.altKey && e.key.toLowerCase() === "l") { e.preventDefault(); toggle(); } });
  addEventListener("resize", padLines);
  new ResizeObserver(padLines).observe(root);
  S.Player.addEventListener("songchange", () => { if (open) load(); });

  const icon = `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z"/></svg>`;
  new S.Topbar.Button("Lyrics Glass (Alt+L)", icon, toggle);
})();
'@
[System.IO.File]::WriteAllText((Join-Path $extDir "lyrics-glass.js"), $js, (New-Object System.Text.UTF8Encoding $false))
Write-Host "==> Extension saved to $extDir\lyrics-glass.js" -ForegroundColor Cyan

# 3. Enable it and apply to Spotify
spicetify config extensions lyrics-glass.js
spicetify backup apply
if ($LASTEXITCODE -ne 0) { spicetify apply }

Write-Host "`nDone! In Spotify: click the music-note button in the top bar, or press Alt+L." -ForegroundColor Green
