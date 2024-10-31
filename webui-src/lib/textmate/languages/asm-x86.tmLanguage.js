export default {
  "$schema": "https://raw.githubusercontent.com/martinring/tmlanguage/master/tmlanguage.json",
  "name": "x86 ASM",
  "comment": "x86 ASM language syntax",
  "scopeName": "source.x86",
  "fileTypes": [
      "asm-x86"
  ],
  "patterns": [
      {
          "include": "#comment"
      },
      {
          "include": "#namespace"
      },
      {
          "include": "#import"
      },
      {
          "include": "#opcode"
      },
      {
          "include": "#register"
      },
      {
          "include": "#annotation"
      },
      {
          "include": "#type-qualifier"
      },
      {
          "include": "#string"
      },
      {
          "include": "#constant"
      },
      {
          "include": "#punctuation"
      },
      {
          "include": "#keyword"
      },
      {
          "include": "#operator"
      },
      {
          "include": "#type"
      },
      {
          "include": "#number"
      },
      {
          "include": "#function"
      },
      {
          "include": "#variable"
      }
  ],
  "repository": {
      "annotation": {
          "begin": "@",
          "end": "$",
          "name": "punctuation.quoted.asm-x86",
          "patterns": [
              {
                  "match": "\\(.*\\)",
                  "name": "punctuation.section.asm-x86"
              }
          ]
      },
      "comment": {
          "patterns": [
              {
                  "begin": "/// ```",
                  "end": "/// ```",
                  "name": "comment.block.documentation.asm-x86",
                  "patterns": [
                      {
                          "begin": "(?<=^ */// )",
                          "end": "$",
                          "name": "comment.block.documentation.asm-x86",
                          "patterns": [
                              {
                                  "include": "#comment"
                              },
                              {
                                  "include": "#namespace"
                              },
                              {
                                  "include": "#import"
                              },
                              {
                                  "include": "#opcode"
                              },
                              {
                                  "include": "#register"
                              },
                              {
                                  "include": "#annotation"
                              },
                              {
                                  "include": "#type-qualifier"
                              },
                              {
                                  "include": "#string"
                              },
                              {
                                  "include": "#constant"
                              },
                              {
                                  "include": "#punctuation"
                              },
                              {
                                  "include": "#keyword"
                              },
                              {
                                  "include": "#operator"
                              },
                              {
                                  "include": "#type"
                              },
                              {
                                  "include": "#number"
                              },
                              {
                                  "include": "#function"
                              },
                              {
                                  "include": "#variable"
                              }
                          ]
                      }
                  ]
              },
              {
                  "begin": "///",
                  "end": "$",
                  "name": "comment.block.documentation.asm-x86",
                  "patterns": [
                      {
                          "begin": "`",
                          "end": "`|$",
                          "name": "comment.block.documentation.asm-x86",
                          "patterns": [
                              {
                                  "include": "#namespace"
                              },
                              {
                                  "include": "#import"
                              },
                              {
                                  "include": "#opcode"
                              },
                              {
                                  "include": "#register"
                              },
                              {
                                  "include": "#annotation"
                              },
                              {
                                  "include": "#type-qualifier"
                              },
                              {
                                  "include": "#string"
                              },
                              {
                                  "include": "#constant"
                              },
                              {
                                  "include": "#punctuation"
                              },
                              {
                                  "include": "#keyword"
                              },
                              {
                                  "include": "#operator"
                              },
                              {
                                  "include": "#type"
                              },
                              {
                                  "include": "#number"
                              },
                              {
                                  "include": "#function"
                              },
                              {
                                  "include": "#variable"
                              }
                          ]
                      },
                      {
                          "match": "(?<=/// )(?:BUG|FIXME|NOTE|TODO|XXX):?",
                          "name": "markup.bold.asm-x86"
                      },
                      {
                          "match": "(?<=/// #+ ).*$",
                          "name": "markup.heading.asm-x86"
                      }
                  ]
              },
              {
                  "begin": "//",
                  "end": "$",
                  "name": "comment.line.double-slash.asm-x86",
                  "patterns": [
                      {
                          "match": "(?<=// )(?:BUG|FIXME|NOTE|TODO|XXX):?",
                          "name": "markup.bold.asm-x86"
                      }
                  ]
              }
          ]
      },
      "constant": {
          "match": "\\b(?:false|null|true|[0-9_]*[A-Z][A-Z0-9_]+)\\b",
          "name": "constant.language.asm-x86"
      },
      "function": {
          "patterns": [
              {
                  "match": "\\b[0-9_]*[a-z][a-z0-9_]*(?=\\s*\\()",
                  "name-other": "entity.name.function.asm-x86",
                  "name": "keyword.operator.asm-x86"
              },
              {
                  "match": "\\b[0-9_]*[a-z][a-z0-9_]*(?=\\s*<.*>\\s*\\()",
                  "name-other": "entity.name.function.asm-x86",
                  "name": "keyword.operator.asm-x86"
              }
          ]
      },
      "import": {
          "begin": "\\b(import)\\b",
          "end": "$",
          "beginCaptures": {
              "1": {
                  "name": "keyword.control.asm-x86"
              }
          },
          "patterns": [
              {
                  "match": "\\b(\\w+)\\b",
                  "name": "punctuation.quoted.asm-x86"
              },
              {
                  "match": ";",
                  "name": "punctuation.terminator.asm-x86"
              },
              {
                  "match": "\\.",
                  "name": "punctuation.separator.asm-x86"
              }
          ]
      },
      "keyword": {
          "match": "(?<=^\\s*|[,<\\]]\\s*)\\b(enum|struct|type|union)\\b",
          "name": "keyword.control.asm-x86"
      },
      "namespace": {
          "match": "\\b[A-Za-z0-9_][A-Za-z0-9_-]+[A-Za-z0-9_](?=::)",
          "name": "entity.name.type.asm-x86",
          "patterns": [
              {
                  "match": ".*",
                  "name": "punctuation.definition.variable.asm-x86"
              }
          ]
      },
      "number": {
          "patterns": [
              {
                  "match": "\\b\\d+(?:\\.\\d+(?:[Ee][+-]?\\d+)?)?([iu](?:8|16|32|64)?|f(?:32|64)?)?\\b",
                  "name": "constant.numeric.asm-x86",
                  "captures": {
                      "1": {
                          "name": "punctuation.separator.asm-x86"
                      }
                  }
              },
              {
                  "match": "\\b(0x)[0-9A-Fa-f']*[0-9A-Fa-f](?:\\.\\h+[Pp][+-]\\d+)?([iu](?:8|16|32|64)?|f(?:32|64)?)?\\b",
                  "name": "constant.numeric.asm-x86",
                  "captures": {
                      "1": {
                          "name": "punctuation.separator.asm-x86"
                      },
                      "2": {
                          "name": "punctuation.separator.asm-x86"
                      }
                  }
              },
              {
                  "match": "\\b(0o)[0-7']*[0-7]([iu](?:8|16|32|64)?|f(?:32|64)?)?\\b",
                  "name": "constant.numeric.asm-x86",
                  "captures": {
                      "1": {
                          "name": "punctuation.separator.asm-x86"
                      },
                      "2": {
                          "name": "punctuation.separator.asm-x86"
                      }
                  }
              },
              {
                  "match": "\\b(0b)[01']*[01]([iu](?:8|16|32|64)?|f(?:32|64)?)?\\b",
                  "name": "constant.numeric.asm-x86",
                  "captures": {
                      "1": {
                          "name": "punctuation.separator.asm-x86"
                      },
                      "2": {
                          "name": "punctuation.separator.asm-x86"
                      }
                  }
              },
              {
                  "match": "\\b0\\S+\\b",
                  "name": "invalid.illegal.asm-x86"
              }
          ]
      },
      "opcode": {
          "match": "(?i)^\\s*(a(a[adms]|d[cd]|nd)|c(all|bw|l[cdi]|m(c|p(s[bw])?)|wd)|d(a[as]|ec|iv)|esc|hlt|i(div|mul|n(c|to?)?|ret)|j(ae?|be?|c(xz)?|e|ge?|le?|mp|n(ae?|be?|c|e|ge?|le?|o|p|s|z)|o|p[eo]?|s|z)|l(ahf|ds|e[as]|o(ck|ds[bw]|opn?[ez]))|m(ov(s[bw])?|ul)|n(eg|o[pt])|o(r|ut)|p(op|ush)f?|r(c[lr]|e(p(n?[ez])?|t[nf]?)|o[lr])|s(a(hf|l|r)|bb|cas[bw]|h[lr]|t(c|d|i|os[bw])|ub)|test|wait|x(chg|lat|or))\\b",
          "name": "keyword.mnemonic.x86.asm-x86"
      },
      "operator": {
          "match": "[+\\-*/%<>=~&^|?:]|!=\\b",
          "name": "keyword.operator.asm-x86"
      },
      "punctuation": {
          "patterns": [
              {
                  "match": ";",
                  "name": "punctuation.terminator.asm-x86"
              },
              {
                  "match": "[,.]|->|::",
                  "name": "punctuation.separator.asm-x86"
              },
              {
                  "match": "[()\\[\\]{}]",
                  "name": "punctuation.section.asm-x86"
              },
              {
                  "begin": "(?<=\\b(?:enum|type|[0-9_]*[A-Z][A-Za-z0-9]*)\\s*)<",
                  "end": ">",
                  "name": "punctuation.separator.asm-x86",
                  "patterns": [
                      {
                          "include": "#type-qualifier"
                      },
                      {
                          "include": "#type"
                      }
                  ]
              }
          ]
      },
      "register": {
          "match": "\\b(AF?|BC?|C|DE?|E|HL?|I[XY]?|L|PC|R|SP)\\b",
          "name": "variable.language.asm-x86"
      },
      "string": {
          "patterns": [
              {
                  "begin": "'",
                  "end": "'",
                  "name": "string.quoted.single.asm-x86"
              },
              {
                  "begin": "\"",
                  "end": "\"",
                  "name": "string.quoted.double.asm-x86",
                  "patterns": [
                      {
                          "match": "\\\\(?:[\"0nrt\\\\]|x\\h\\h|u\\h\\h\\h\\h)",
                          "name": "constant.character.escape.asm-x86"
                      },
                      {
                          "match": "\\\\(?:x\\h*|u\\h*|.)",
                          "name": "invalid.illegal.asm-x86"
                      }
                  ]
              }
          ]
      },
      "type": {
          "begin": "\\b([iu](?:8|16|32|64)|f(?:32|64)|bool|void|[A-Z](?:[A-Z0-9]*[a-z][A-Za-z0-9-]*)?)\\b",
          "end": "(?!\\s*[\\[<(&*?])",
          "name": "entity.name.type.asm-x86",
          "patterns": [
              {
                  "comment": "A subpattern for matching the derived type qualifier: '?'",
                  "match": "\\?",
                  "name": "storage.modifier.asm-x86"
              },
              {
                  "comment": "A subpattern for matching the left associative derived type qualifiers: '*' and '&'",
                  "match": "[&*](?:\\s*['\"])?(?:\\s*const\\b)?(?:\\s*volatile\\b)?",
                  "name": "storage.modifier.asm-x86"
              },
              {
                  "comment": "The array type derivation",
                  "begin": "\\[",
                  "end": "\\]",
                  "name": "punctuation.section.asm-x86",
                  "patterns": [
                      {
                          "include": "#namespace"
                      },
                      {
                          "include": "#type-qualifier"
                      },
                      {
                          "include": "#string"
                      },
                      {
                          "include": "#constant"
                      },
                      {
                          "include": "#punctuation"
                      },
                      {
                          "include": "#keyword"
                      },
                      {
                          "include": "#operator"
                      },
                      {
                          "include": "#type"
                      },
                      {
                          "include": "#number"
                      },
                      {
                          "include": "#function"
                      },
                      {
                          "include": "#variable"
                      }
                  ]
              }
          ]
      },
      "type-qualifier": {
          "match": "\\b(?:const|mutable|safe|volatile)\\b",
          "name": "storage.modifier.asm-x86"
      },
      "variable": {
          "match": "\\b[0-9]*[a-z_][a-z0-9_]*\\b",
          "name": "variable.other.asm-x86"
      }
  }
}
