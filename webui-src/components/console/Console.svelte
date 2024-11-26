<script>
  import { onMount } from 'svelte';

  import { Terminal } from '@xterm/xterm';
  import { FitAddon } from '@xterm/addon-fit';
  import { CanvasAddon } from '@xterm/addon-canvas';

  export let tab;
  export let redirectKeydownEvent;
  export let xterm;
  export let showHelp;
  let xterm_el;
  
  xterm = new Terminal({
    allowTransparency: false,
    cursorStyle: 'bar',
    cursorInactiveStyle: 'none',
    disableStdin: true,
    convertEol: true,
    theme: {
      background: "#1e1e1e",
      cursor: "#1e1e1e",
      cursorAccent: "#1e1e1e",
      green: "#c5f467",
      red: "#ff8484",
    }
  });

  const fitAddon = new FitAddon();
  const canvasAddon = new CanvasAddon();

  xterm.loadAddon(canvasAddon);
  xterm.loadAddon(fitAddon);

  xterm.onKey(({ domEvent }) => {
    if(domEvent.ctrlKey && domEvent.code === "KeyC"){
      navigator.clipboard.writeText(xterm.getSelection());
    } else {
      redirectKeydownEvent(domEvent);
    }
  });

  function redColor(text){
    return `\x1b[31m${text}\x1b[0m`;
  }

  function greenColor(text){
    return `\x1b[32m${text}\x1b[0m`;
  }

  window.receiveBuildInfo = function receiveBuildInfo(exitCode, stdout, stderr){
    xterm.write(stdout);
    xterm.write(redColor(stderr));
    const exitText = `Le programme de compilation de la Nboard a quitté avec le code ${exitCode} ! (${exitCode === 0 ? "OK" : "ERREUR"})\n`;
    xterm.write(exitCode === 0 ? greenColor(exitText) : redColor(exitText));
    xterm.scrollToBottom();
    if(exitCode !== 0){
      tab.set("console");
    }
  }

  window.failLog = function failLog(message, trace){
    console.warn(message, "\n", trace);
    try {
      trace = trace.split("\n").filter(t => !t.startsWith("???")).join("\n").split("C:").filter(t => t.indexOf("resources\\nboard\\src") != -1).map(t => t.split("src\\")[1].replace(/0x.*\n/, "\n")).join("");
    } catch(e){
      trace = "";
      console.error("Parsing trace error:", e);
    }

    if(trace === ""){
      xterm.write(redColor(`ERREUR ${message}\n`));
    } else {
      xterm.write(redColor(`ERREUR ${message}:\n`));
      xterm.write(redColor(trace));
    }

    tab.set("console");
  }

  showHelp = function showHelp(){
    xterm.clear();
    xterm.write([
      "###########################################",
      "# Université Paris-Saclay - IUT de Cachan #",
      "#    Simulateur Nboard - Tristan HAMEL    #",
      "###########################################",
      "",
      "Bienvenue dans le simulateur de Nboard !",
      "Ici tu trouveras tout ce dont tu as besoin pour t'entrainer.",
      "",
      "La Nboard est complétement interactive depuis la souris !",
      "Il existe néanmoins des raccourcis pour aller plus vite :",
      " - Appuyez sur les touches 0, 1, 2 et 3 pour les boutons poussoirs",
      " - Appuyez sur les flèches pour la direction et sur espace pour le centre du joystick",
      " - Appuyez sur + ou - pour le codeur incrémental",
      "",
      "Vous avez également tout les raccourcis de base du menu Simulateur :",
      " - Ctrl+S : Sauvegarde le code de main.c et de nb_api.c",
      " - Ctrl+C : Copie du texte sélectionné dans l'onglet correspondant",
      " - Ctrl+V : Colle du texte dans l'onglet correspondant",
      " - Ctrl+B : Compile le code de la Nboard",
      " - F5     : Compile le code et lance la Nboard",
      " - Ctrl+L : Lance la Nboard",
      " - Ctrl+K : Arrête la Nboard",
      " - Ctrl+R : Redémarre la Nboard",
      " - Ctrl+O : Ouvre le dossier de code de la Nboard sur Visual Studio Code si installé",
      "",
      "Tu peu retrouver ce texte en ouvrant le menu Simulateur et en appuyant sur Aide !",
    ].join('\n') + "\n");
  }

  onMount(() => {
    xterm.open(xterm_el);
    showHelp();

    requestAnimationFrame(function fit(){
      fitAddon.fit();
      requestAnimationFrame(fit);
    });
  });
</script>

<div class="console" bind:this={xterm_el} />

<style lang="scss">
  :global(.xterm .xterm-viewport) {
    scrollbar-color: #4f4f4f #0000;
    scrollbar-width: thin;
  }

  .console {
    position: absolute;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;

    overflow: hidden;
  }
</style>