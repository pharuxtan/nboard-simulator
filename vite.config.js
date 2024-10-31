import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import { sveltePreprocess } from 'svelte-preprocess';
import { preprocessMeltUI, sequence } from '@melt-ui/pp';
import { resolve, basename } from 'node:path';
import autoprefixer from 'autoprefixer';

const isDev = process.env.NODE_ENV != 'production';

export default defineConfig({
  root: 'webui-src',
  resolve: {
    alias: {
      '$assets': resolve(__dirname, './webui-src/assets'),
      '$lib': resolve(__dirname, './webui-src/lib'),
    }
  },
  plugins: [
    svelte({
      onwarn(warning, handler){
        if (warning.code === "a11y-click-events-have-key-events") return;
        if (warning.code === "a11y-no-static-element-interactions") return;
        if (warning.code === "a11y-no-noninteractive-element-interactions") return;
        console.warn('warn:', warning.code);
        handler(warning);
      },
      preprocess: sequence([
        sveltePreprocess(),
        preprocessMeltUI()
      ])
    }),
    {
      name: "add-webui",
      apply: "build",
      transformIndexHtml(html){
        return {
          html,
          tags: [
            {
              tag: "script",
              attrs: {
                src: "webui.js"
              },
              injectTo: "body"
            }
          ]
        }
      },
    },
  ],
  build: {
    chunkSizeWarningLimit: Infinity,
    sourcemap: isDev,
    emptyOutDir: true,
    outDir: `../build/${ isDev ? "Debug" : "Release" }/resources`,
    assetsDir: "app",
    rollupOptions: {
      cache: true,
      output: {
        assetFileNames: 'app/assets/[name]-[hash].[ext]',
        manualChunks: (modulePath) => {
          if(modulePath.includes('/node_modules/')){
            if(modulePath.includes('monaco-editor')){
              return 'vendor/monaco-editor';
            } else if(modulePath.includes('melt-ui')){
              return 'vendor/melt-ui';
            } else if(modulePath.includes('xterm')){
              return 'vendor/xterm';
            } else {
              return 'vendor/common';
            }
          } else if(modulePath.includes('/textmate/')){
            if(modulePath.includes('/languages')){
              return 'textmate/languages/' + basename(modulePath).split('.tmLanguage')[0];
            } else if(modulePath.includes('/themes')){
              return 'textmate/themes/' + basename(modulePath).split('.')[0];
            }
            return 'textmate/tm';
          }
          return 'index';
        }
      }
    }
  },
  publicDir: "../static",
  css: {
    preprocessorOptions: {
      scss: {
        silenceDeprecations: ['legacy-js-api']
      }
    },
    postcss: {
      plugins: [
        autoprefixer()
      ]
    }
  }
});
