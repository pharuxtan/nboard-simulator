import { Registry, INITIAL } from 'vscode-textmate';
import { loadWASM, OnigScanner, OnigString } from 'vscode-oniguruma';
import onigWASM from 'vscode-oniguruma/release/onig.wasm?url';
import { TMToMonacoToken } from './helper.js';

import cppTmLanguage from './languages/cpp.tmLanguage.js';
import cppEmbeddedMacroTmLanguage from './languages/cpp.embedded.macro.tmLanguage.js';
import cTmLanguage from './languages/c.tmLanguage.js';
import regexpPythonTmLanguage from './languages/regexp.python.tmLanguage.js';
import glslTmLanguage from './languages/glsl.tmLanguage.js';
import asmTmLanguage from './languages/asm.tmLanguage.js';
import asmX86TmLanguage from './languages/asm-x86.tmLanguage.js';
import asmX8664TmLanguage from './languages/asm-x86_64.tmLanguage.js';
import asmArmTmLanguage from './languages/asm-arm.tmLanguage.js';

export { convertTheme } from './helper.js';

const wasmPromise = fetch(onigWASM)
  .then(res => res.arrayBuffer())
  .then(data => loadWASM({ data }))
  .catch(err => console.error('Failed to load `onig.wasm`:', error));

const scopeMap = {
  'source.c': cTmLanguage,
  'source.cpp': cppTmLanguage,
  'source.cpp.embedded.macro': cppEmbeddedMacroTmLanguage,
  'source.asm': asmTmLanguage,
  'source.regexp.python': regexpPythonTmLanguage,
  'source.glsl': glslTmLanguage,
  'source.x86': asmX86TmLanguage,
  'source.x86_64': asmX8664TmLanguage,
  'source.arm': asmArmTmLanguage,
};

const registry = new Registry({
  onigLib: wasmPromise.then(_ => {
    return {
      createOnigScanner: sources => new OnigScanner(sources),
      createOnigString: str => new OnigString(str),
    };
  }),
  async loadGrammar(scopeName){
    if(scopeName in scopeMap)
      return scopeMap[scopeName];

    throw new Error(`No grammar found for scope: ${scopeName}`);
  }
});

async function createTokensProvider(scopeName, colorTheme){
  const grammar = await registry.loadGrammar(scopeName);

  return {
    getInitialState(){
      return INITIAL;
    },
    tokenize(line, state){
      const lineTokens = grammar.tokenizeLine(line, state);
      const tokens = [];
      for(const token of lineTokens.tokens){
        tokens.push({
          startIndex: token.startIndex,
          scopes: colorTheme
            ? TMToMonacoToken(colorTheme, token.scopes)
            : token.scopes.slice(-1)[0],
        });
      }
      return { tokens, endState: lineTokens.ruleStack };
    },
  };
}

export class TokensProviderCache {
  cache = {};

  constructor(colorTheme){
    this.colorTheme = colorTheme;
  }

  async getTokensProvider(scopeName){
    if(scopeName in this.cache)
      return this.cache[scopeName];

    return this.cache[scopeName] = await createTokensProvider(scopeName, this.colorTheme);
  }
}