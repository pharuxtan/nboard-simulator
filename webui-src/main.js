import App from './App.svelte';
import './global.scss';
import '@xterm/xterm/css/xterm.css';

// Add the global "window" if the page is launched in the WebView and not in the Browser
if(typeof window === "undefined") globalThis.window = globalThis;

/* Setup Monaco Editor */
import monaco from '$lib/monaco.js';

import editorWorker from 'monaco-editor/esm/vs/editor/editor.worker?worker';
import { TokensProviderCache, convertTheme } from '$lib/textmate/tm.js';
import darkPlusTheme from '$lib/textmate/themes/dark-plus.js';

self.MonacoEnvironment = {
  getWorker(){
    return new editorWorker();
  }
}

const convertedDarkPlustheme = convertTheme(darkPlusTheme);
monaco.editor.defineTheme('dark-plus', convertedDarkPlustheme);

const cache = new TokensProviderCache(darkPlusTheme);

cache.getTokensProvider('source.cpp').then(tokensProvider => {
  monaco.languages.setTokensProvider('cpp', tokensProvider);
});

cache.getTokensProvider('source.c').then(tokensProvider => {
  monaco.languages.setTokensProvider('c', tokensProvider);
});

/* Launch App */
const app = new App({
	target: document.body
});

export default app;