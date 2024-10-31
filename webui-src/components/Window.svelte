<script>
  import { melt, createMenubar, createTabs } from '@melt-ui/svelte';

  import Nboard from './nboard/Nboard.svelte';
  import Monaco from './monaco/Monaco.svelte';
  import Console from './console/Console.svelte';

  let xterm = null;
  let showHelp = null;
  let editor = null;

  let saved = true;

  const { elements: { menubar }, builders: { createMenu } } = createMenubar();
  const { elements: { menu: menuMenu, item: menuItem, trigger: menuTrigger, separator: menuSeparator } } = createMenu({ positioning: { overflowPadding: 0, gutter: 2 } });
  
  const { elements: { root: tabRoot, list: tabList, content: tabContent, trigger: tabTrigger }, states: { value: tabValue } } = createTabs({
    defaultValue: 'nboard'
  });

  function keydownAction(e){
    if(e.repeat) return;
    if(e.code === "F5"){
      e.preventDefault();
      e.stopPropagation();
      actionMenu("build-run");
    } else if(e.ctrlKey){
      switch(e.code){
        case "KeyS":
          e.preventDefault();
          e.stopPropagation();
          actionMenu("save");
          break;
        case "KeyO":
          e.preventDefault();
          e.stopPropagation();
          actionMenu("open-vscode");
          break;
        case "KeyB":
          e.preventDefault();
          e.stopPropagation();
          actionMenu("build");
          break;
        case "KeyL":
          e.preventDefault();
          e.stopPropagation();
          actionMenu("run");
          break;
        case "KeyK":
          e.preventDefault();
          e.stopPropagation();
          actionMenu("stop");
          break;
        case "KeyR":
          e.preventDefault();
          e.stopPropagation();
          actionMenu("reset");
          break;
      }
    }
  }

  document.addEventListener("keydown", keydownAction);

  async function actionMenu(id){
    if(typeof id !== "string") id = id.target.id;

    if(id === "help"){
      showHelp();
      tabValue.set('console');
    } if(id === "save"){
      saved = true;
      saveMain(editor.getValue());
    } else if(id === "build"){
      xterm.clear();
      xterm.write("Compilation de la Nboard...\n");
      xterm.scrollToBottom();
      buildNboard();
    } else if(id === "build-run"){
      xterm.clear();
      xterm.write("Compilation et lancement de la Nboard...\n");
      xterm.scrollToBottom();
      buildAndRunNboard();
    } else if(id === "run"){
      xterm.write("Lancement de la Nboard...\n");
      xterm.scrollToBottom();
      runNboard();
    } else if(id === "stop"){
      xterm.write("Arrêt de la Nboard...\n");
      xterm.scrollToBottom();
      stopNboard();
    } else if(id === "reset"){
      xterm.write("Redémarrage de la Nboard...\n");
      xterm.scrollToBottom();
      resetNboard();
    } else if(id === "copy"){
      if($tabValue === 'console'){
        navigator.clipboard.writeText(xterm.getSelection());
      } else if($tabValue === 'monaco'){
        navigator.clipboard.writeText(editor.getModel().getValueInRange(editor.getSelection()));
      }
    } else if(id === "paste"){
      if($tabValue === 'monaco'){
        const text = await navigator.clipboard.readText();
        editor.trigger('keyboard', 'type', { text });
      }
    } else if(id === "open-vscode"){
      openVSC();
    } else {
      console.log("menu:", id);
    }
  }

  function editorChange(){
    saved = false;
  }
</script>

<div class="window" use:melt={$tabRoot}>
  <div class="upper inter-400">
    <div class="menubar" use:melt={$menubar}>
      <button class="menu-title" use:melt={$menuTrigger}>Simulateur</button>
      <div use:melt={$menuMenu} class="menu inter-400">
        <div class="section" shortcut="CTRL+S" id="save" use:melt={$menuItem} on:m-click={actionMenu}>Sauvegarder</div>
        <div class="section" shortcut="CTRL+C" id="copy" use:melt={$menuItem} on:m-click={actionMenu}>Copier</div>
        <div class="section" shortcut="CTRL+V" id="paste" use:melt={$menuItem} on:m-click={actionMenu}>Coller</div>
        <div class="separator" use:melt={$menuSeparator} />
        <div class="section" shortcut="CTRL+B" id="build" use:melt={$menuItem} on:m-click={actionMenu}>Compiler</div>
        <div class="section" shortcut="F5" id="build-run" use:melt={$menuItem} on:m-click={actionMenu}>Compiler et Lancer</div>
        <div class="separator" use:melt={$menuSeparator} />
        <div class="section" shortcut="CTRL+L" id="run" use:melt={$menuItem} on:m-click={actionMenu}>Lancer</div>
        <div class="section" shortcut="CTRL+K" id="stop" use:melt={$menuItem} on:m-click={actionMenu}>Arrêter</div>
        <div class="section" shortcut="CTRL+R" id="reset" use:melt={$menuItem} on:m-click={actionMenu}>Redémarrer</div>
        <div class="separator" use:melt={$menuSeparator} />
        <div class="section" shortcut="CTRL+O" id="open-vscode" use:melt={$menuItem} on:m-click={actionMenu}>Ouvrir dans VSCode</div>
        <div class="section" shortcut="" id="help" use:melt={$menuItem} on:m-click={actionMenu}>Aide</div>
      </div>
    </div>
    <div class="tabs" use:melt={$tabList}>
      <button class="tab nboard" use:melt={$tabTrigger("nboard")}>Nboard</button>
      <button class="tab console" use:melt={$tabTrigger("console")}>Console</button>
      <button class="tab editor" use:melt={$tabTrigger("monaco")}>Editeur de code{saved ? '' : ' - Non sauvegardé'}</button>
    </div>
  </div>
  
  <div class="windows">
    <div use:melt={$tabContent('nboard')} class="tab">
      <Nboard focus={$tabValue === 'nboard'} tab={tabValue} />
    </div>
    <div use:melt={$tabContent('monaco')} class="tab">
      <Monaco bind:editor={editor} on:change={editorChange} />
    </div>
    <div use:melt={$tabContent('console')} class="tab">
      <Console bind:xterm={xterm} bind:showHelp={showHelp} tab={tabValue} redirectKeydownEvent={keydownAction} />
    </div>
  </div>
</div>

<style lang="scss">
  * {
    outline: none;
  }

  .menu {
    background-color: #3c3c3c;
    color: #fff;

    display: flex;
    flex-direction: column;

    padding: 5px;

    z-index: 9;

    .section, .separator {
      &:not(:last-child) {
        margin-bottom: 5px;
      }
    }

    .section {
      cursor: pointer;
      padding: 6px 10px;
      border-radius: 5px;

      background-color: #3c3c3c;

      transition: .1s background-color;

      &::after {
        content: attr(shortcut);
        position: sticky;
        left: 100%;
        margin-left: 15px;
        font-size: 0.75em;
      }

      &:hover {
        background-color: #4c4c4c;
      }
    }

    .separator {
      border: 1px solid #2c2c2c;
    }

    * {
      user-select: none;
    }
  }

  .upper {
    width: 100%;
    height: 23px;

    border-bottom: 2px solid #191919;

    display: flex;
    flex-direction: row;

    background-color: #1e1e1e;

    button {
      height: 100%;

      background-color: #1e1e1e;
      color: #fff;
      cursor: pointer;
      letter-spacing: 1px;

      outline: none;
      border: none;

      transition: .1s background-color;

      &:hover, &[data-state=open], &[data-state=active] {
        background-color: #3c3c3c;
      }
    }

    .menubar {
      display: flex;
      flex-direction: row;

      border-right: 2px solid #191919;

      .menu-title:nth-last-child(n + 3) {
        margin-right: 2px;
      }
    }

    .tabs {
      display: flex;
      flex-direction: row;

      width: 100%;

      .tab {
        &.nboard, &.console {
          width: 20%;
        }

        &.editor {
          width: 60%;
        }

        &:not(:last-child) {
          margin-right: 2px;
        }
      }
    }

    * {
      user-select: none;
    }
  }
  
  .windows {
    position: relative;
    flex-grow: 1;

    .tab {
      display: contents;

      &[hidden=true] {
        visibility: hidden;
      }
    }
  }

  .window {
    display: contents;
  }
</style>