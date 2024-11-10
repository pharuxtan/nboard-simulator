<script>
  import { onMount, onDestroy, createEventDispatcher } from 'svelte';
  
  import monaco from '$lib/monaco.js';
  
  const dispatch = createEventDispatcher();

  export let file;
  export let editor;
  let editor_el;
  
  window.open = function noop(){};

  onMount(async () => {
    editor = monaco.editor.create(editor_el, {
      value: await readFile(file),
      language: 'c',
      theme: 'dark-plus',
      automaticLayout: true,
      mouseWheelZoom: true,
      minimap: {
        enabled: false
      }
    });

    editor.getModel().onDidChangeContent(() => {
      dispatch('change');
    });
  });

  onDestroy(() => {
    editor.dispose();
  });
</script>

<div class="editor" bind:this={editor_el}></div>

<style lang="scss">
  .editor {
    position: absolute;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;

    overflow: hidden;
  }
</style>