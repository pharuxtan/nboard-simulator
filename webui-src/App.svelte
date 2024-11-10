<script>
  import Window from "./components/Window.svelte";
  
  import nboardImage from '$assets/nboard.webp?url';
  import nboardFont from '$assets/DroidSansMono.woff2?url';
  import interFont from '$assets/Inter.woff2?url';
  import icon from '$assets/icon.png?url';

  let start = false;

  const importedFuncs = [
    "readFile", "saveFile",
    "setPin", "setAnain",
    "runNboard", "stopNboard", "resetNboard", "buildNboard", "buildAndRunNboard",
    "updateContext", "isBuilding", "isRunning",
    "openVSC"
  ];

  window.addEventListener('keydown', (e) => {
    if(e.code === "F12"){
      e.preventDefault();
      e.stopPropagation();
    }
  });

  const interval = setInterval(() => {
    if(typeof webui !== "undefined"){
      let willStart = true;
      for(let func of importedFuncs){
        if(typeof webui[func] === "undefined"){
          willStart = false;
          break;
        }
      }
      if(willStart){
        start = true;
        clearInterval(interval);
      }
    }
  });
</script>

<svelte:head>
  <link rel="icon" href="{icon}" />
  <link rel="prefetch" crossorigin href="{nboardImage}" as="image" type="image/webp" />
  <link rel="prefetch" crossorigin href="{nboardFont}" as="font" type="font/woff2" />
  <link rel="prefetch" crossorigin href="{interFont}" as="font" type="font/woff2" />
</svelte:head>

<div class="app" class:loading={!start}>
  {#if !start}
    <div class="loading inter-400">Loading...</div>
  {:else}
    <Window />
  {/if}
</div>

<style lang="scss">
  :global(body){
    background-color: #1e1e1e;
  }

  @font-face {
    font-family: 'Inter';
    font-style: normal;
    font-weight: 100 900;
    font-display: swap;
    src: url('$assets/Inter.woff2') format('woff2');
    unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
  }

  .app {
    position: absolute;
    top: 0px;
    left: 0px;

    width: 100vw;
    height: 100vh;

    display: flex;
    flex-direction: column;

    overflow: hidden;

    &.loading {
      align-items: center;
      justify-content: center;
    }

    .loading {
      font-size: 5vmin;
      color: #e1e1e1;
    }
  }
</style>