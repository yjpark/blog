(function () {
  var root = document.documentElement;

  function getStoredTheme() {
    try { return localStorage.getItem('theme'); } catch (e) { return null; }
  }

  function storeTheme(theme) {
    try { localStorage.setItem('theme', theme); } catch (e) {}
  }

  function getSystemTheme() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    return 'light';
  }

  function applyTheme(theme) {
    root.classList.toggle('dark', theme === 'dark');
  }

  function setupToggle() {
    var button = document.getElementById('theme-toggle');
    if (!button) return;
    button.onclick = function () {
      var isDark = root.classList.toggle('dark');
      storeTheme(isDark ? 'dark' : 'light');
    };
  }

  applyTheme(getStoredTheme() || getSystemTheme());
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupToggle);
  } else {
    setupToggle();
  }
})();
