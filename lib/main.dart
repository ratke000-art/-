<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
<title>KI Video Studio</title>
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
<style>
  :root {
    --bg:#14101F; --bg-elev:#1B1530; --surface:#241C3D; --surface-2:#2E2350;
    --text:#F5F1FA; --muted:#A79BC4; --accent:#FF5C7A; --accent-2:#FFD23F; --accent-3:#7B6EF6;
    --border: rgba(245,241,250,0.09);
    --radius-lg: 22px; --radius-md: 14px; --radius-sm: 10px;
    --font-display: 'Space Grotesk', sans-serif; --font-body: 'Inter', sans-serif;
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --bg:#14101F; --bg-elev:#1B1530; --surface:#241C3D; --text:#F5F1FA; --muted:#A79BC4; --border: rgba(245,241,250,0.09);
    }
  }
  :root[data-theme="light"] {
    --bg:#F1ECFA; --bg-elev:#FFFFFF; --surface:#FFFFFF; --surface-2:#F1ECFA;
    --text:#1E1730; --muted:#6C6280; --border: rgba(20,16,31,0.09);
  }
  :root[data-theme="dark"] {
    --bg:#14101F; --bg-elev:#1B1530; --surface:#241C3D; --text:#F5F1FA; --muted:#A79BC4; --border: rgba(245,241,250,0.09);
  }
  * { box-sizing: border-box; }
  html, body { height: 100%; margin: 0; }
  html { scroll-padding-top: env(safe-area-inset-top, 0px); }
  body {
    background: var(--bg); color: var(--text); font-family: var(--font-body);
    -webkit-font-smoothing: antialiased;
  }
  button, input, textarea { font-family: inherit; color: inherit; }
  button:focus-visible, input:focus-visible, textarea:focus-visible { outline: 2px solid var(--accent-2); outline-offset: 2px; }

  .app {
    max-width: 480px; margin: 0 auto; min-height: 100dvh;
    display: flex; flex-direction: column; background: var(--bg); position: relative; overflow: hidden;
  }

  /* ---- header ---- */
  .topbar {
    position: sticky; top: 0; z-index: 20;
    padding: calc(env(safe-area-inset-top, 0px) + 14px) 16px 12px;
    display: flex; align-items: center; justify-content: space-between;
    background: linear-gradient(180deg, var(--bg) 70%, transparent);
  }
  .icon-btn {
    width: 42px; height: 42px; border-radius: 50%; border: 1px solid var(--border);
    background: var(--surface); color: var(--text); font-size: 18px; cursor: pointer;
    display: flex; align-items: center; justify-content: center; transition: background .15s ease;
  }
  .icon-btn:hover { background: var(--surface-2); }

  .mascot-wrap { display: flex; align-items: center; gap: 10px; }
  .mascot-bubble {
    font-family: var(--font-display); font-size: 12.5px; font-weight: 600;
    background: var(--surface); border: 1px solid var(--border); color: var(--text);
    padding: 7px 12px; border-radius: 14px 14px 4px 14px; max-width: 168px;
    opacity: 1; transition: opacity .3s ease; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  }
  .mascot {
    position: relative; width: 46px; height: 46px; border-radius: 14px;
    background: linear-gradient(145deg, var(--accent), var(--accent-3));
    display: flex; align-items: center; justify-content: center;
    animation: mascot-sway 3.6s ease-in-out infinite;
    box-shadow: 0 6px 18px rgba(255,92,122,0.35);
    flex-shrink: 0;
  }
  .mascot-hash { font-family: var(--font-display); font-weight: 700; font-size: 24px; color: var(--bg); }
  .mascot-eyes {
    position: absolute; top: 9px; left: 50%; transform: translateX(-50%);
    font-size: 8px; letter-spacing: 2px; color: var(--accent-2);
  }
  @keyframes mascot-sway {
    0%, 100% { transform: translateY(0) rotate(-4deg); }
    50% { transform: translateY(-5px) rotate(4deg); }
  }

  /* ---- drawer ---- */
  .drawer { position: fixed; inset: 0; z-index: 40; }
  .drawer-backdrop { position: absolute; inset: 0; background: rgba(10,8,16,0.55); }
  .drawer-panel {
    position: absolute; top: 0; left: 0; bottom: 0; width: min(300px, 82vw);
    background: var(--bg-elev); padding: calc(env(safe-area-inset-top,0px) + 24px) 22px 22px;
    display: flex; flex-direction: column; gap: 14px;
    box-shadow: 12px 0 32px rgba(0,0,0,0.35);
    animation: drawer-in .22s ease-out;
  }
  @keyframes drawer-in { from { transform: translateX(-16px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
  .drawer-panel h2 { font-family: var(--font-display); font-size: 19px; margin: 0 0 4px; }
  .stat-row { display: flex; align-items: baseline; gap: 8px; }
  .stat-num { font-family: var(--font-display); font-size: 30px; font-weight: 700; color: var(--accent-2); }
  .stat-label { color: var(--muted); font-size: 13.5px; }
  .drawer-note { color: var(--muted); font-size: 13px; line-height: 1.5; margin-top: 6px; }
  .drawer-panel button.btn-secondary { margin-top: auto; }

  /* ---- chat ---- */
  .chat {
    flex: 1; overflow-y: auto; padding: 4px 16px 12px; display: flex; flex-direction: column; gap: 16px;
    scroll-padding-top: env(safe-area-inset-top, 0px);
  }
  .bubble { display: flex; flex-direction: column; max-width: 86%; }
  .bubble-ki { align-self: flex-start; align-items: flex-start; }
  .bubble-ich { align-self: flex-end; align-items: flex-end; }
  .bubble-label { font-family: var(--font-display); font-size: 11px; letter-spacing: .04em; color: var(--muted); margin-bottom: 4px; padding: 0 4px; }
  .bubble-content {
    padding: 12px 14px; border-radius: var(--radius-md); font-size: 15px; line-height: 1.5;
  }
  .bubble-ki .bubble-content { background: var(--surface); border: 1px solid var(--border); border-top-left-radius: 4px; }
  .bubble-ich .bubble-content { background: var(--accent); color: #241021; border-top-right-radius: 4px; font-weight: 500; }
  .bubble-content p { margin: 0 0 8px; }
  .bubble-content p:last-child { margin-bottom: 0; }

  .chip-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 6px; }
  .chip {
    border: 1px solid var(--border); background: var(--surface-2); color: var(--text);
    padding: 8px 13px; border-radius: 999px; font-size: 13.5px; cursor: pointer; transition: transform .12s ease, background .15s ease;
  }
  .chip:hover { background: var(--accent-3); color: #fff; }
  .chip:active { transform: scale(0.96); }

  /* ---- video generation / result card ---- */
  .video-card { display: flex; flex-direction: column; gap: 10px; min-width: 220px; }
  .video-status { display: flex; align-items: center; gap: 8px; margin: 0; font-size: 14.5px; }
  .video-status .pct { color: var(--accent-2); font-family: var(--font-display); font-weight: 600; }
  .dots span { animation: dot-pulse 1.2s infinite; opacity: .2; }
  .dots span:nth-child(2) { animation-delay: .2s; }
  .dots span:nth-child(3) { animation-delay: .4s; }
  @keyframes dot-pulse { 0%, 100% { opacity: .2; } 50% { opacity: 1; } }
  .progress-track { height: 8px; border-radius: 6px; background: var(--surface-2); overflow: hidden; }
  .progress-fill { height: 100%; width: 0%; background: linear-gradient(90deg, var(--accent), var(--accent-2)); transition: width .25s ease; }

  .video-title { font-family: var(--font-display); font-weight: 600; font-size: 16px; margin: 0; }
  .video-player { width: 100%; max-width: 240px; border-radius: var(--radius-sm); background: #000; align-self: center; aspect-ratio: 9 / 16; }
  .result-actions { display: flex; }
  .btn-primary, .btn-secondary {
    border: none; border-radius: 999px; padding: 11px 18px; font-size: 14px; font-weight: 600; cursor: pointer; width: 100%;
  }
  .btn-primary { background: var(--accent); color: #241021; }
  .btn-primary:disabled { opacity: .6; }
  .btn-secondary { background: var(--surface-2); color: var(--text); border: 1px solid var(--border); }

  .rating-block { display: flex; flex-direction: column; gap: 8px; padding-top: 6px; border-top: 1px solid var(--border); }
  .rating-block p { margin: 0; font-size: 13.5px; color: var(--muted); }
  .stars { display: flex; gap: 4px; }
  .star { background: none; border: none; font-size: 24px; line-height: 1; color: var(--surface-2); cursor: pointer; padding: 2px; }
  .star.active { color: var(--accent-2); }
  textarea#feedbackText {
    resize: vertical; min-height: 54px; border-radius: var(--radius-sm); border: 1px solid var(--border);
    background: var(--surface-2); color: var(--text); padding: 10px; font-size: 13.5px;
  }

  /* ---- ad banner + composer ---- */
  .footer {
    position: sticky; bottom: 0; z-index: 20;
    padding: 10px 16px calc(env(safe-area-inset-bottom, 0px) + 12px);
    background: linear-gradient(0deg, var(--bg) 75%, transparent); display: flex; flex-direction: column; gap: 10px;
  }
  .ad-banner {
    display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: var(--radius-sm);
    border: 1px dashed var(--border); color: var(--muted); font-size: 12.5px; background: var(--bg-elev);
  }
  .ad-tag {
    font-family: var(--font-display); font-size: 10px; letter-spacing: .05em; padding: 2px 7px; border-radius: 5px;
    background: var(--surface-2); color: var(--muted); flex-shrink: 0;
  }
  .composer { display: flex; align-items: center; gap: 8px; }
  .composer input {
    flex: 1; border: 1px solid var(--border); background: var(--surface); color: var(--text);
    border-radius: 999px; padding: 12px 16px; font-size: 15px;
  }
  .mic-btn.listening { background: var(--accent); color: #241021; animation: mic-pulse 1s infinite; }
  @keyframes mic-pulse { 0%,100% { box-shadow: 0 0 0 0 rgba(255,92,122,.5); } 50% { box-shadow: 0 0 0 8px rgba(255,92,122,0); } }
  .send-btn {
    width: 42px; height: 42px; border-radius: 50%; border: none; background: var(--accent); color: #241021;
    font-size: 17px; cursor: pointer; flex-shrink: 0;
  }

  [hidden] { display: none !important; }

  @media (prefers-reduced-motion: reduce) {
    * { animation-duration: .001ms !important; animation-iteration-count: 1 !important; transition-duration: .001ms !important; }
  }
</style>
</head>
<body>
<div class="app">

  <header class="topbar">
    <button type="button" class="icon-btn" id="menuBtn" aria-label="Menü öffnen">☰</button>
    <div class="mascot-wrap">
      <div class="mascot-bubble" id="mascotBubble">Lass uns loslegen! 🎬</div>
      <div class="mascot" aria-hidden="true">
        <span class="mascot-eyes">••</span>
        <span class="mascot-hash">#</span>
      </div>
    </div>
  </header>

  <div class="drawer" id="drawer" hidden>
    <div class="drawer-backdrop" id="drawerBackdrop"></div>
    <div class="drawer-panel">
      <h2>Dein Fortschritt</h2>
      <div class="stat-row"><span class="stat-num" id="lvlNum">2</span><span class="stat-label">Fragen stellt die KI dir gerade vor jedem Video</span></div>
      <div class="stat-row"><span class="stat-num" id="vidCount">0</span><span class="stat-label">Videos bisher erstellt</span></div>
      <p class="drawer-note">Je mehr Videos wir zusammen machen, desto mehr fragt die KI nach und desto besser trifft sie deinen Stil. Verlauf &amp; Einstellungen kommen hier bald dazu.</p>
      <button type="button" class="btn-secondary" id="drawerClose">Schließen</button>
    </div>
  </div>

  <main class="chat" id="chat"></main>

  <footer class="footer">
    <div class="ad-banner"><span class="ad-tag">Anzeige</span><span>Werbeplatz – Platzhalter</span></div>
    <form class="composer" id="composerForm">
      <button type="button" class="icon-btn mic-btn" id="micBtn" aria-label="Spracheingabe">🎤</button>
      <input type="text" id="composerInput" placeholder="Schreibe und erstelle …" autocomplete="off" />
      <button type="submit" class="send-btn" aria-label="Senden">➤</button>
    </form>
  </footer>

</div>

<script>
(function () {
  'use strict';

  // ---------- DOM ----------
  const chatEl = document.getElementById('chat');
  const composerForm = document.getElementById('composerForm');
  const composerInput = document.getElementById('composerInput');
  const micBtn = document.getElementById('micBtn');
  const menuBtn = document.getElementById('menuBtn');
  const drawer = document.getElementById('drawer');
  const drawerBackdrop = document.getElementById('drawerBackdrop');
  const drawerClose = document.getElementById('drawerClose');
  const lvlNum = document.getElementById('lvlNum');
  const vidCount = document.getElementById('vidCount');
  const mascotBubble = document.getElementById('mascotBubble');

  // ---------- helpers ----------
  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  }
  function isHex(s) { return typeof s === 'string' && /^#([0-9a-fA-F]{6})$/.test(s.trim()); }
  function scrollBottom() { chatEl.scrollTop = chatEl.scrollHeight; }

  function addBubble(role, html) {
    const wrap = document.createElement('div');
    wrap.className = 'bubble ' + (role === 'ich' ? 'bubble-ich' : 'bubble-ki');
    wrap.innerHTML = '<span class="bubble-label">' + (role === 'ich' ? 'Ich' : 'KI') + '</span><div class="bubble-content">' + html + '</div>';
    chatEl.appendChild(wrap);
    scrollBottom();
    return wrap;
  }

  // ---------- capabilities ----------
  let sampleCap = null, dbCap = null, downloadsCap = null, userCap = null, uid = null;

  async function initCapabilities() {
    try {
      if (window.claude && window.claude.use) {
        const results = await Promise.all([
          window.claude.use('sample').catch(() => null),
          window.claude.use('db').catch(() => null),
          window.claude.use('downloads').catch(() => null),
          window.claude.use('user').catch(() => null),
        ]);
        sampleCap = results[0]; dbCap = results[1]; downloadsCap = results[2]; userCap = results[3];
        if (userCap) { uid = await userCap.id().catch(() => null); }
      }
    } catch (e) { console.warn('capability init failed', e); }
  }

  // ---------- state (self-improvement) ----------
  const QUESTION_BANK = [
    { key: 'stil', q: 'In welchem Stil soll dein Video sein?', options: ['Verspielt', 'Episch', 'Minimalistisch', 'Chaotisch-witzig'] },
    { key: 'stimmung', q: 'Welche Stimmung soll rüberkommen?', options: ['Motivierend', 'Ruhig', 'Aufregend', 'Nachdenklich'] },
    { key: 'tempo', q: 'Wie schnell soll geschnitten werden?', options: ['Schnell & knackig', 'Gemütlich & fließend'] },
    { key: 'farben', q: 'Welche Farbwelt passt dazu?', options: ['Neon-Pop', 'Pastell', 'Dunkel & kontrastreich', 'Warm & erdig'] },
    { key: 'zielgruppe', q: 'Für wen ist das Video gedacht?', options: ['Nur für mich', 'Social-Media-Follower', 'Kund:innen / Business'] },
    { key: 'musik', q: 'Welche Klanguntermalung?', options: ['Energiegeladen', 'Sanft & ambient', 'Kein Ton'] },
  ];

  let appState = { videosCreated: 0, questionCount: 2, learnedPrefs: [] };

  function recomputeQuestionCount() {
    appState.questionCount = Math.min(2 + Math.floor(appState.videosCreated / 2), QUESTION_BANK.length);
  }

  async function loadState() {
    try {
      if (dbCap && uid) {
        const snap = await dbCap.doc('data/users/' + uid + '/profile').get();
        if (snap.exists) { const d = snap.data(); appState = Object.assign({}, appState, d); }
      } else {
        const raw = localStorage.getItem('kivs_state');
        if (raw) appState = Object.assign({}, appState, JSON.parse(raw));
      }
    } catch (e) { console.warn('state load failed', e); }
    recomputeQuestionCount();
    updateDrawerStats();
  }

  async function saveState() {
    recomputeQuestionCount();
    try {
      if (dbCap && uid) {
        await dbCap.doc('data/users/' + uid + '/profile').set(appState);
      } else {
        localStorage.setItem('kivs_state', JSON.stringify(appState));
      }
    } catch (e) { console.warn('state save failed', e); }
    updateDrawerStats();
  }

  function updateDrawerStats() {
    lvlNum.textContent = appState.questionCount;
    vidCount.textContent = appState.videosCreated;
  }

  // ---------- mascot sayings ----------
  const SAYINGS = ['Lass uns was drehen! 🎬', 'Ich lern mit jedem Video dazu 🧠', 'Skript? Schon dabei ✍️', 'Frag mich einfach los 😄', 'Auflösung: gestochen scharf ✨', 'Ich merk mir, was dir gefällt 💾'];
  let sIdx = 0;
  function rotateSaying() {
    mascotBubble.style.opacity = 0;
    setTimeout(() => { mascotBubble.textContent = SAYINGS[sIdx % SAYINGS.length]; sIdx++; mascotBubble.style.opacity = 1; }, 250);
  }

  // ---------- drawer ----------
  menuBtn.addEventListener('click', () => { drawer.hidden = false; });
  drawerBackdrop.addEventListener('click', () => { drawer.hidden = true; });
  drawerClose.addEventListener('click', () => { drawer.hidden = true; });

  // ---------- mic (Web Speech API) ----------
  function setupMic() {
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SR) { micBtn.style.display = 'none'; return; }
    const recog = new SR();
    recog.lang = 'de-DE';
    recog.interimResults = true;
    recog.continuous = false;
    let listening = false;
    recog.onresult = (e) => {
      let text = '';
      for (let i = 0; i < e.results.length; i++) text += e.results[i][0].transcript;
      composerInput.value = text;
    };
    recog.onend = () => { listening = false; micBtn.classList.remove('listening'); };
    recog.onerror = () => { listening = false; micBtn.classList.remove('listening'); };
    micBtn.addEventListener('click', () => {
      if (listening) { recog.stop(); return; }
      try { recog.start(); listening = true; micBtn.classList.add('listening'); } catch (e) { /* ignore */ }
    });
  }

  // ---------- conversation flow ----------
  let conv = null;

  function pickQuestions() { return QUESTION_BANK.slice(0, appState.questionCount); }

  function startConversation() {
    addBubble('ki', '<p>Hey! Ich bin deine Video-KI. Gerade frage ich dich <strong>' + appState.questionCount + '</strong> Dinge, bevor ich loslege — je mehr Videos wir zusammen machen, desto mehr frage ich nach und desto besser treffe ich deinen Stil.</p><p>Worum soll’s in deinem Video gehen?</p>');
    conv = { stage: 'idea', idea: '', answers: {}, qIndex: 0, questions: pickQuestions() };
  }

  composerForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const val = composerInput.value;
    composerInput.value = '';
    handleComposerSubmit(val);
  });

  chatEl.addEventListener('click', (e) => {
    const chip = e.target.closest('.chip');
    if (chip && chip.dataset.value) {
      addBubble('ich', escapeHtml(chip.dataset.value));
      recordAnswer(chip.dataset.value);
    }
  });

  function handleComposerSubmit(raw) {
    const text = raw.trim();
    if (!text || !conv) return;
    if (conv.stage === 'idea') {
      addBubble('ich', escapeHtml(text));
      conv.idea = text;
      conv.stage = 'questions';
      askNextQuestion();
    } else if (conv.stage === 'questions') {
      addBubble('ich', escapeHtml(text));
      recordAnswer(text);
    } else if (conv.stage === 'done' || conv.stage === null) {
      addBubble('ich', escapeHtml(text));
      conv = { stage: 'questions', idea: text, answers: {}, qIndex: 0, questions: pickQuestions() };
      askNextQuestion();
    }
    // while 'generating' or mid-rating, plain composer text is ignored — the UI controls handle those steps
  }

  function recordAnswer(value) {
    const item = conv.questions[conv.qIndex];
    conv.answers[item.key] = value;
    conv.qIndex++;
    askNextQuestion();
  }

  function askNextQuestion() {
    if (conv.qIndex >= conv.questions.length) {
      conv.stage = 'generating';
      generateVideoFlow();
      return;
    }
    const item = conv.questions[conv.qIndex];
    const chips = item.options.map(o => '<button type="button" class="chip" data-value="' + escapeHtml(o) + '">' + escapeHtml(o) + '</button>').join('');
    addBubble('ki', '<p>' + escapeHtml(item.q) + '</p><div class="chip-row">' + chips + '</div>');
  }

  // ---------- storyboard (the "script") ----------
  function localStoryboard(idea) {
    return {
      title: idea ? idea.slice(0, 40) : 'Mein Video',
      colors: ['#2D1B69', '#FF5C7A', '#FFD23F'],
      mood: 'bright',
      scenes: [
        { heading: idea ? idea.slice(0, 26) : 'Deine Idee', sub: 'Los geht’s …' },
        { heading: 'Schritt 1', sub: 'Der Anfang zählt' },
        { heading: 'Schritt 2', sub: 'Es nimmt Fahrt auf' },
        { heading: 'Schritt 3', sub: 'Der Höhepunkt' },
        { heading: 'Jetzt du!', sub: 'Zeig, was du kannst' },
      ],
    };
  }

  function sanitizeStoryboard(data, idea) {
    const fb = localStoryboard(idea);
    if (!data || typeof data !== 'object') return fb;
    let colors = Array.isArray(data.colors) ? data.colors.filter(isHex) : [];
    if (colors.length < 3) colors = fb.colors; else colors = colors.slice(0, 3);
    const scenesRaw = Array.isArray(data.scenes) && data.scenes.length ? data.scenes : fb.scenes;
    const scenes = scenesRaw.slice(0, 6).map((s, i) => ({
      heading: (s && typeof s.heading === 'string' && s.heading.trim()) ? s.heading.trim().slice(0, 40) : fb.scenes[i % fb.scenes.length].heading,
      sub: (s && typeof s.sub === 'string') ? s.sub.trim().slice(0, 80) : '',
    }));
    const mood = ['energetic', 'calm', 'mysterious', 'bright'].includes(data.mood) ? data.mood : fb.mood;
    const title = (typeof data.title === 'string' && data.title.trim()) ? data.title.trim().slice(0, 60) : fb.title;
    return { title: title, colors: colors, mood: mood, scenes: scenes.length ? scenes : fb.scenes };
  }

  async function buildStoryboard(idea, answers) {
    if (!sampleCap) return localStoryboard(idea);
    const answersText = Object.keys(answers).length ? Object.entries(answers).map(([k, v]) => '- ' + k + ': ' + v).join('\n') : '- (keine)';
    const prefsText = appState.learnedPrefs.length ? appState.learnedPrefs.join('; ') : 'noch keine';
    const prompt = 'Du planst ein kurzes vertikales Social-Media-Video (ca. 16-20 Sekunden, 5 Szenen).\n' +
      'Idee der Person: "' + idea + '"\n' +
      'Antworten auf Rückfragen:\n' + answersText + '\n' +
      'Bereits gelernte Vorlieben aus früheren Videos dieser Person: ' + prefsText + '\n\n' +
      'Antworte NUR mit einem JSON-Objekt, ohne einleitenden Text, in diesem Format:\n' +
      '{"title": "kurzer Videotitel, max 40 Zeichen", "colors": ["#hex1","#hex2","#hex3"], "mood": "energetic|calm|mysterious|bright", "scenes": [{"heading":"max 26 Zeichen","sub":"max 58 Zeichen"}]}\n' +
      'Erzeuge genau 5 Szenen als kleinen Spannungsbogen (Aufhänger, 3 Entwicklungsschritte, Abschluss mit Call-to-Action). ' +
      '"colors" sind 3 zur Stimmung passende Hex-Farben (Hintergrund-Verlauf + Akzent). Schreibe auf Deutsch.';
    try {
      const data = await sampleCap.json(prompt, { modelTier: 'default', cache: false });
      return sanitizeStoryboard(data, idea);
    } catch (e) {
      console.warn('sample.json failed, using local storyboard', e);
      return localStoryboard(idea);
    }
  }

  // ---------- canvas video rendering ----------
  function hexWithAlpha(hex, alpha) {
    const h = hex.replace('#', '');
    const r = parseInt(h.substring(0, 2), 16), g = parseInt(h.substring(2, 4), 16), b = parseInt(h.substring(4, 6), 16);
    return 'rgba(' + r + ',' + g + ',' + b + ',' + alpha + ')';
  }
  function roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
  }
  function wrapText(ctx, text, x, y, maxWidth, lineHeight) {
    if (!text) return;
    const words = text.split(' ');
    const lines = [];
    let line = '';
    for (const w of words) {
      const test = line ? line + ' ' + w : w;
      if (ctx.measureText(test).width > maxWidth && line) { lines.push(line); line = w; } else { line = test; }
    }
    if (line) lines.push(line);
    const totalH = lines.length * lineHeight;
    const startY = y - totalH / 2 + lineHeight / 2;
    lines.forEach((l, i) => ctx.fillText(l, x, startY + i * lineHeight));
  }

  function drawFrame(ctx, W, H, storyboard, elapsed, sceneDur) {
    const sceneCount = storyboard.scenes.length;
    const idx = Math.min(Math.floor(elapsed / sceneDur), sceneCount - 1);
    const t = Math.min((elapsed - idx * sceneDur) / sceneDur, 1);
    const scene = storyboard.scenes[idx];
    const c0 = storyboard.colors[0], c1 = storyboard.colors[1], c2 = storyboard.colors[2];

    const angle = (elapsed / 6000) % (Math.PI * 2);
    const cx = W / 2 + Math.cos(angle) * W * 0.15;
    const cy = H * 0.35 + Math.sin(angle) * H * 0.08;
    const grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, H * 0.9);
    grad.addColorStop(0, c1);
    grad.addColorStop(1, c0);
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, W, H);

    for (let i = 0; i < 3; i++) {
      const bx = W * 0.5 + Math.sin(angle * 1.3 + i * 2) * W * 0.32;
      const by = H * 0.6 + Math.cos(angle * 0.9 + i * 1.7) * H * 0.18;
      ctx.beginPath();
      ctx.fillStyle = hexWithAlpha(c2, 0.10);
      ctx.arc(bx, by, 180 + i * 40, 0, Math.PI * 2);
      ctx.fill();
    }

    let alpha = 1;
    if (t < 0.15) alpha = t / 0.15; else if (t > 0.85) alpha = (1 - t) / 0.15;

    ctx.save();
    ctx.globalAlpha = alpha;
    ctx.textAlign = 'center';
    ctx.fillStyle = '#F5F1FA';
    ctx.font = "700 84px 'Space Grotesk', sans-serif";
    wrapText(ctx, scene.heading, W / 2, H * 0.46, W * 0.82, 92);
    ctx.font = "500 38px 'Inter', sans-serif";
    ctx.fillStyle = 'rgba(245,241,250,0.85)';
    wrapText(ctx, scene.sub || '', W / 2, H * 0.58, W * 0.78, 50);
    ctx.restore();

    const segGap = 10, segW = (W - 40 - segGap * (sceneCount - 1)) / sceneCount;
    for (let i = 0; i < sceneCount; i++) {
      const x = 20 + i * (segW + segGap);
      ctx.fillStyle = 'rgba(255,255,255,0.25)';
      roundRect(ctx, x, 50, segW, 8, 4); ctx.fill();
      if (i <= idx) {
        const fillW = i < idx ? segW : segW * t;
        ctx.fillStyle = c2;
        roundRect(ctx, x, 50, fillW, 8, 4); ctx.fill();
      }
    }

    ctx.globalAlpha = 0.8;
    ctx.font = "600 30px 'Space Grotesk', sans-serif";
    ctx.fillStyle = 'rgba(245,241,250,0.55)';
    ctx.textAlign = 'left';
    ctx.fillText('# KI Video Studio', 30, H - 50);
  }

  function startAmbientPad(ctx, dest, mood) {
    const freqSets = {
      energetic: [261.6, 329.6, 392.0, 523.3],
      calm: [220, 277.2, 329.6],
      mysterious: [220, 261.6, 311.1],
      bright: [293.7, 370.0, 440.0],
    };
    const freqs = freqSets[mood] || freqSets.bright;
    const master = ctx.createGain();
    master.gain.value = 0.0001;
    master.connect(dest);
    master.connect(ctx.destination);
    const oscs = freqs.map((f, i) => {
      const o = ctx.createOscillator();
      o.type = i === 0 ? 'sine' : 'triangle';
      o.frequency.value = f;
      const g = ctx.createGain();
      g.gain.value = 0;
      o.connect(g).connect(master);
      o.start();
      return { o: o, g: g };
    });
    const now = ctx.currentTime;
    master.gain.linearRampToValueAtTime(0.05, now + 0.6);
    oscs.forEach((entry, i) => {
      entry.g.gain.setValueAtTime(0, now);
      entry.g.gain.linearRampToValueAtTime(0.6 / (i + 1), now + 0.6 + i * 0.15);
    });
    const lfo = ctx.createOscillator();
    lfo.frequency.value = mood === 'energetic' ? 2.2 : 0.35;
    const lfoGain = ctx.createGain();
    lfoGain.gain.value = 0.02;
    lfo.connect(lfoGain).connect(master.gain);
    lfo.start();
    return {
      stop: function () {
        const t = ctx.currentTime;
        try { master.gain.cancelScheduledValues(t); master.gain.linearRampToValueAtTime(0.0001, t + 0.3); } catch (e) {}
        setTimeout(() => {
          oscs.forEach(o => { try { o.o.stop(); } catch (e) {} });
          try { lfo.stop(); } catch (e) {}
        }, 400);
      }
    };
  }

  function renderVideo(storyboard, onProgress) {
    return new Promise((resolve, reject) => {
      if (!window.MediaRecorder) { reject(new Error('MediaRecorder wird hier nicht unterstützt.')); return; }
      const W = 1080, H = 1920;
      const canvas = document.createElement('canvas');
      canvas.width = W; canvas.height = H;
      canvas.style.position = 'fixed'; canvas.style.left = '-9999px'; canvas.style.top = '0';
      document.body.appendChild(canvas);
      const ctx = canvas.getContext('2d');
      const sceneDur = 3200;
      const total = storyboard.scenes.length * sceneDur;

      let videoStream;
      try { videoStream = canvas.captureStream(30); }
      catch (e) { canvas.remove(); reject(e); return; }

      let mixedStream = videoStream, audioCtx = null, pad = null;
      try {
        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const dest = audioCtx.createMediaStreamDestination();
        pad = startAmbientPad(audioCtx, dest, storyboard.mood);
        mixedStream = new MediaStream(videoStream.getVideoTracks().concat(dest.stream.getAudioTracks()));
      } catch (e) { console.warn('audio setup failed, rendering silently', e); }

      const mimeCandidates = ['video/webm;codecs=vp9,opus', 'video/webm;codecs=vp8,opus', 'video/webm'];
      const mimeType = mimeCandidates.find(m => MediaRecorder.isTypeSupported(m)) || 'video/webm';
      let recorder;
      try { recorder = new MediaRecorder(mixedStream, { mimeType: mimeType, videoBitsPerSecond: 6000000 }); }
      catch (e) { cleanup(); reject(e); return; }

      const chunks = [];
      recorder.ondataavailable = (e) => { if (e.data && e.data.size) chunks.push(e.data); };
      recorder.onerror = (e) => { cleanup(); reject(e.error || new Error('Aufnahmefehler')); };
      recorder.onstop = () => {
        cleanup();
        const blob = new Blob(chunks, { type: 'video/webm' });
        resolve({ blob: blob, url: URL.createObjectURL(blob) });
      };

      function cleanup() {
        if (pad) pad.stop();
        if (audioCtx) audioCtx.close().catch(() => {});
        canvas.remove();
      }

      const start = performance.now();
      recorder.start(200);
      function frame(now) {
        const elapsed = now - start;
        drawFrame(ctx, W, H, storyboard, Math.min(elapsed, total), sceneDur);
        onProgress(Math.min(elapsed / total, 1));
        if (elapsed < total) requestAnimationFrame(frame);
        else setTimeout(() => { try { recorder.stop(); } catch (e) { cleanup(); reject(e); } }, 150);
      }
      requestAnimationFrame(frame);
    });
  }

  // ---------- video UI flow ----------
  function addVideoCard() {
    const bubble = document.createElement('div');
    bubble.className = 'bubble bubble-ki';
    bubble.innerHTML = '<span class="bubble-label">KI</span><div class="bubble-content"><div class="video-card">' +
      '<p class="video-status">Video wird erstellt <span class="dots"><span>.</span><span>.</span><span>.</span></span></p>' +
      '<div class="progress-track"><div class="progress-fill"></div></div></div></div>';
    chatEl.appendChild(bubble);
    scrollBottom();
    return { el: bubble, statusEl: bubble.querySelector('.video-status'), fillEl: bubble.querySelector('.progress-fill'), cardEl: bubble.querySelector('.video-card') };
  }

  function setProgress(card, pct, label) {
    card.fillEl.style.width = Math.max(0, Math.min(100, pct)) + '%';
    if (label) card.statusEl.innerHTML = escapeHtml(label) + ' <span class="pct">' + Math.round(pct) + '%</span>';
  }

  function addRetryButton(card) {
    const btn = document.createElement('button');
    btn.type = 'button'; btn.className = 'btn-secondary'; btn.textContent = 'Nochmal versuchen'; btn.style.marginTop = '8px';
    btn.addEventListener('click', () => { generateVideoFlow(); });
    card.cardEl.appendChild(btn);
  }

  async function generateVideoFlow() {
    const card = addVideoCard();
    setProgress(card, 5, 'Skript wird geschrieben');
    let storyboard;
    try { storyboard = await buildStoryboard(conv.idea, conv.answers); }
    catch (e) { storyboard = localStoryboard(conv.idea); }
    setProgress(card, 25, 'Video wird gerendert');
    try {
      const result = await renderVideo(storyboard, (pct) => setProgress(card, 25 + pct * 70, 'Video wird gerendert'));
      setProgress(card, 100, 'Fertig');
      showResult(card, storyboard, result.blob, result.url);
    } catch (e) {
      console.error('render failed', e);
      card.statusEl.textContent = 'Beim Rendern ist etwas schiefgelaufen.';
      addRetryButton(card);
    }
  }

  function showResult(card, storyboard, blob, url) {
    card.cardEl.innerHTML =
      '<p class="video-title">' + escapeHtml(storyboard.title) + '</p>' +
      '<video class="video-player" src="' + url + '" controls playsinline loop></video>' +
      '<div class="result-actions"><button type="button" class="btn-primary" id="dlBtn">Video herunterladen</button></div>' +
      '<div class="rating-block"><p>Wie gut passt das Video?</p>' +
      '<div class="stars" id="starsRow">' + [1, 2, 3, 4, 5].map(n => '<button type="button" class="star" data-star="' + n + '">★</button>').join('') + '</div>' +
      '<textarea id="feedbackText" placeholder="Was können wir nächstes Mal besser machen? (optional)"></textarea>' +
      '<button type="button" class="btn-secondary" id="submitRating">Speichern &amp; nächstes Video</button></div>';
    wireResultActions(card, blob);
    scrollBottom();
  }

  function wireResultActions(card, blob) {
    const starsRow = card.el.querySelector('#starsRow');
    let selected = 0;
    starsRow.addEventListener('click', (e) => {
      const btn = e.target.closest('.star');
      if (!btn) return;
      selected = Number(btn.dataset.star);
      Array.prototype.forEach.call(starsRow.children, s => s.classList.toggle('active', Number(s.dataset.star) <= selected));
    });

    const dlBtn = card.el.querySelector('#dlBtn');
    if (downloadsCap) {
      dlBtn.addEventListener('click', async () => {
        dlBtn.disabled = true; dlBtn.textContent = 'Speichere …';
        try {
          await downloadsCap.save({ filename: 'ki-video-' + Date.now() + '.webm', data: blob });
          dlBtn.textContent = 'Gespeichert ✓';
        } catch (e) {
          dlBtn.textContent = 'Video herunterladen';
        } finally { dlBtn.disabled = false; }
      });
    } else { dlBtn.style.display = 'none'; }

    card.el.querySelector('#submitRating').addEventListener('click', async () => {
      const feedback = card.el.querySelector('#feedbackText').value.trim();
      await finishVideo(selected, feedback);
    });
  }

  async function finishVideo(rating, feedback) {
    appState.videosCreated += 1;
    if (rating >= 4 && feedback) {
      appState.learnedPrefs.push(feedback.slice(0, 140));
      if (appState.learnedPrefs.length > 5) appState.learnedPrefs.shift();
    }
    await saveState();
    conv.stage = 'done';
    addBubble('ki', '<p>Danke, das merk ich mir fürs nächste Mal. Jetzt frage ich dich beim nächsten Video <strong>' + appState.questionCount + '</strong> Dinge. Erzähl mir einfach deine nächste Idee, wenn du magst.</p>');
  }

  // ---------- boot ----------
  (async function boot() {
    await initCapabilities();
    await loadState();
    setupMic();
    rotateSaying();
    setInterval(rotateSaying, 4200);
    startConversation();
  })();

})();
</script>
</body>
</html>
