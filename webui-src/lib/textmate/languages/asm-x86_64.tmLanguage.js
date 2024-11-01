export default {
	"name": "Fasm",
	"scopeName": "source.x86_64",
	"fileTypes": ["fasm", "asm", "inc"],
	"patterns": [
	{
		"include": "#registers"
	},
	{
		"include": "#commands"
	},
	{
		"include": "#numbers"
	},
	{
		"include": "#strings"
	},
	{
		"include": "#sections"
	},
	{
		"name": "comment.line.double-slash.documentation.c",
		"match": "\\s?(;.*)",
		"captures": {
			"0": { "name": "comment.line.double-slash.documentation.c" }
		},
		"comment": "Comments"
	},
	{
		"name": "storage.type",
		"match": "(\\t| )(db|rb|dw|du|rw|dd|rd|dp|df|rp|rf|dq|rq|dt|rt|byte|word|dword|fword|pword|qword|tbyte|tword|dqword|xword|qqword|yword|dqqword|zword)(\\t| )",
		"captures": {
		"1": { "name": "storage.type" }
		},
		"comment": "Names Pseudo Instructions case insensitive"
	},
	{
		"name": "keyword.control",
		"match": "^[\\t| ]{0,}(include|format|entry)\\b"
	},
	{
		"name": "keyword.control",
		"match": "(\\[|\\]|,|:|\\+|-|\\*|/)",
		"comment": "Simbols"
	},
	{
		"name": "support.function.constant",
		"match": "\\b[A-Z]{1,1}[_A-Z0-9]{0,}\\b",
		"captures": {
			"0": { "name": "support.function.constant" }
		},
		"comment": "Define"
	}],
	"repository":
	{
		"sections":
		{
			"patterns": [
			{
				"match": "(^[\\t| ]{0,}section\\s+)(('.*')|(\".*\"))(.*?)((?=;)|(\\n))",
				"captures":
				{
					"1":
					{
						"name": "entity.name.section"
					},
					"2":
					{
						"patterns": [
						{
							"include": "#strings"
						}]
					},
					"5":
					{
						"name": "entity.name.section"
					}
				},
				"comment": "Section"
			}]
		},
		"strings":
		{
			"patterns": [
			{
				"match": "(')(.*)(')",
				"captures":
				{
					"0":
					{
						"name": "keyword.control"
					},
					"2":
					{
						"name": "string.quoted.double.c"
					}
				},
				"comment": "Quoted single"
			},
			{
				"match": "(\")(.*)(\")",
				"captures":
				{
					"0":
					{
						"name": "keyword.control"
					},
					"2":
					{
						"name": "string.quoted.double.c"
					}
				},
				"comment": "Quoted double"
			}]
		},
		"registers":
		{
			"patterns": [
			{
				"name": "entity.name.type",
				"match": "\\b(?i:al|ah|ax|eax|bl|bh|bx|ebx|cl|ch|cx|ecx|dl|dh|dx|edx|si|esi|di|edi|bp|ebp|sp|esp|cs|ds|ss|es|fs|gs|ip|eip|eflags|id|vip|vif|ac|vm|rf|nt|iopl|of|df|if|tf|sf|zf|af|pf|cf|st0|st1|st2|st3|st4|st5|st6|st7|ss0|ss1|ss2|esp0|esp1|esp2|mm0|mm1|mm2|mm3|mm4|mm5|mm6|mm7|xmm0|xmm1|xmm2|xmm3|xmm4|xmm5|xmm6|xmm7|xmcrt|cr0|cr2|cr3|cr4|gdtr|ldtr|idtr|dr0|dr1|dr2|dr3|dr6|dr7|msr|rax|rbx|rcx|rdx|rsi|rdi|rsp|rbp|r8|r9|r10|r11|r12|r13|r14|r15|r8d|r9d|r10d|r11d|r12d|r13d|r14d|r15d|r8w|r9w|r10w|r11w|r12w|r13w|r14w|r15w|r8l|r9l|r10l|r11l|r12l|r13l|r14l|r15l)\\b",
				"captures": {
				"1": { "name": "entity.name.type" }
				},
				"comment": "Names registers case insensitive"
			}]
		},
		"commands":
		{
			"patterns": [
			{
				"name": "support.function.8086/8088",
				"match": "\\b(?i:aaa|aad|aam|aas|adc|add|and|call|cbw|clc|cld|cli|cmc|cmp|cmpsb|cmpsw|cwd|daa|das|dec|div|esc|hlt|idiv|imul|in|inc|int|into|iret|ja|jae|jb|jbe|jc|jcxz|je|jg|jge|jl|jle|jna|jnae|jnb|jnbe|jnc|jne|jng|jnge|jnl|jnle|jno|jnp|jns|jnz|jo|jp|jpe|jpo|js|jz|jmp|lahf|lar|lds|lea|les|lock|lodsb|lodsw|loop|loope|loopz|loopnz|loopne|mov|movs|movsb|movsw|mul|neg|nop|not|or|out|pop|popf|push|pushf|rcl|rcr|rep|repe|repne|repnz|repz|ret|retn|retf|rol|ror|sahf|sal|sar|sbb|scasb|scasw|shl|shr|stc|std|sti|stosb|stosw|sub|test|wait|xchg|xlat|xor)\\b",
				"captures": {
				"1": {"name": "support.function.8086/8088" }
				},
				"comment": "Function 8086/8088 case insensitive"
			},
			{
				"name": "support.function.80186/80188",
				"match": "\\b(?i:bound|enter|ins|leave|outs|popa|pusha)\\b",
				"captures": {
				"1": { "name": "support.function.80186/80188" }
				},
				"comment": "Function 80186/80188 case insensitive"
			},
			{
				"name": "support.function.80286",
				"match": "\\b(?i:arpl|clts|lar|lgdt|lidt|lldt|lmsw|loadall|lsl|ltr|sgdt|sidt|sldt|smsw|str|verr|verw)\\b",
				"captures": {
				"1": { "name": "support.function.80286" }
				},
				"comment": "Function 80286 case insensitive"
			},
			{
				"name": "support.function.80386",
				"match": "\\b(?i:bsf|bsr|bt|btc|btr|bts|cdq|cmpsd|cwde|insb|insw|insd|iret|iretd|jcxz|jecxz|lsf|lgs|lss|lodsd|loopw|loopd|loopew|looped|loopzw|loopzd|loopnew|loopned|loopnzw|loopnzd|movsw|movsd|movsx|movzx|popad|popfd|pushad|pushfd|scasd|seta|setae|setb|setbe|setc|sete|setg|setge|setl|setle|setna|setnae|setnb|setnbe|setnc|setne|setng|setnge|setnl|setnle|setno|setnp|setns|setnz|seto|setp|setpe|setpo|sets|setz|shld|shrd|stosb|stosw)\\b",
				"captures": {
				"1": { "name": "support.function.80386" }
				},
				"comment": "Function 80386 case insensitive"
			},
			{
				"name": "support.function.80486",
				"match": "\\b(?i:bswap|cmpxchg|invd|invlpg|wbinvd|xadd)\\b",
				"captures": {
				"1": { "name": "support.function.80484" }
				},
				"comment": "Function 80486 case insensitive"
			},
			{
				"name": "support.function.pentium",
				"match": "\\b(?i:cpuid|cmpxchg8b|rdmsr|rdtsc|wrmsr|rsm)\\b",
				"captures": {
				"1": { "name": "support.function.pentium" }
				},
				"comment": "Function Pentium case insensitive"
			},
			{
				"name": "support.function.mmx",
				"match": "\\b(?i:rdpmc|emms|movd|movq|packssdw|packsswb|packuswb|paddb|paddd|paddsb|paddsw|paddusb|paddusw|paddw|pand|pandn|pcmpeqb|pcmpeqd|pcmpeqw|pcmpgtb|pcmpgtd|pcmpgtw|pmaddwd|pmulhw|pmullw|por|pslld|psllq|psllw|psrad|psraw|psrld|psrlq|psrlw|psubb|psubd|psubsb|psubsw|psubusb|psubusw|psubw|punpckhbw|punpckhdq|punpckhwd|punpcklbw|punpckldq|punpcklwd|pxor|paveb|paddsiw|pmagw|pdistib|psubsiw|pmvzb|pmulhrw|pmvnzb|pmvlzb|pmvgezb|pmulhriw|pmachriw)\\b",
				"captures": {
				"1": { "name": "support.function.mmx" }
				},
				"comment": "Function Pentium MMX case insensitive"
			},
			{
				"name": "support.function.3dnow!",
				"match": "\\b(?i:syscall|sysret|femms|pavgusb|pf2id|pfacc|pfadd|pfcmpeq|pfcmpge|pfcmpgt|pfmax|pfmin|pfmul|pfrcp|pfrcpit1|pfrcpit2|pfrsqit1|pfrsqrt|pfsub|pfsubr|pi2fd|pmulhrw|prefetch|prefetchw|pf2iw|pfnacc|pfpnacc|pi2fw|pswapd)\\b",
				"captures": {
				"1": { "name": "support.function.3dnow!" }
				},
				"comment": "Function Pentium case insensitive"
			},
			{
				"name": "support.function.pentiumpro",
				"match": "\\b(?i:cmova|cmovae|cmovb|cmovbe|cmovc|cmove|cmovg|cmovge|cmovl|cmovle|cmovna|cmovnae|cmovnb|cmovnbe|cmovnc|cmovne|cmovng|cmovnge|cmovnl|cmovnle|cmovno|cmovnp|cmovns|cmovnz|cmovo|cmovp|cmovpe|cmovpo|cmovs|cmovz|sysenter|sysexit|ud2|fcmov|fcmovb|fcmovbe|fcmove|fcmovnb|fcmovnbe|fcmovne|fcmovnu|fcmovu|fcomi|fcomip|fucomi|fucomip)\\b",
				"captures": {
				"1": { "name": "support.function.pentiumpro" }
				},
				"comment": "Function Pentium Pro case insensitive"
			},
			{
				"name": "support.function.sse",
				"match": "\\b(?i:maskmovq|movntps|movntq|prefetch0|prefetch1|prefetch2|prefetchnta|sfence|fxrstor|fxsave)\\b",
				"captures": {
				"1": { "name": "support.function.sse" }
				},
				"comment": "Function SSE case insensitive"
			},
			{
				"name": "support.function.sse.simd.float",
				"match": "\\b(?i:addps|addss|cmpps|cmpss|comiss|cvtpi2ps|cvtps2pi|cvtsi2ss|cvtss2si|cvttps2pi|cvttss2si|divps|divss|ldmxcsr|maxps|maxss|minps|minss|movaps|movhlps|movhps|movlhps|movlps|movmskps|movntps|movss|movups|mulps|mulss|rcpps|rcpss|rsqrtps|rsqrtss|shufps|sqrtps|sqrtss|stmxcsr|subps|subss|ucomiss|unpckhps|unpcklps)\\b",
				"captures": {
				"1": { "name": "support.function.sse.float" }
				},
				"comment": "Function SSE case insensitive"
			},
			{
				"name": "support.function.sse.int",
				"match": "\\b(?i:andnps|andps|orps|pavgb|pavgw|pextrw|pinsrw|pmaxsw|pmaxub|pminsw|pminub|pmovmskb|pmulhuw|psadbw|pshufw|xorps|maskmovq|psadbw|pmaxsw|pminsw|movntq|pmulhuw|pavgw|pavgb|pmaxub|pminub|pmovmskb|shufps|pextrw|pinsrw|cmpss|cmpps|sfence|stmxcsr|ldmxcsr|pshufw|maxss|maxps|divss|divps|minss|minps|subss|subps|mulss|mulps|addss|addps|xorps|orps|andnps|andps|rcpss|rcpps|rsqrtss|rsqrtp|sqrtss|sqrtps|comiss|ucomiss|cvtss2si|cvtps2pi|cvttss2si|cvttps2pi|movntps|cvtsi2ss|cvtpi2ps|movaps|movaps|prefetch2|prefetch1|prefetch0|prefetchnta|movhps|movlhps|movhps|unpckhps|unpcklps|movlps|movhlps|movlps|movss|movups|movss|movups)\\b",
				"captures": {
				"1": { "name": "support.function.sse.int" }
				},
				"comment": "Function SSE case insensitive"
			},
			{
				"name": "support.function.sse2",
				"match": "\\b(?i:clflush|lfence|maskmovdqu|mfence|movntdq|movnti|movntpd|pause|addpd|addsd|andnpd|andpd|cmppd|cmpsd|comisd|cvtdq2pd|cvtdq2ps|cvtpd2dq|cvtpd2pi|cvtpd2ps|cvtpi2pd|cvtps2dq|cvtps2pd|cvtsd2si|cvtsd2ss|cvtsi2sd|cvtss2sd|cvttpd2dq|cvttpd2pi|cvttps2dq|cvttsd2si|divpd|divsd|maxpd|maxsd|minpd|minsd|movapd|movhpd|movlpd|movmskpd|movsd|movupd|mulpd|mulsd|orpd|shufpd|sqrtpd|sqrtsd|subpd|subsd|ucomisd|unpckhpd|unpcklpd|xorpd|movdq2q|movdqa|movdqu|movq2dq|paddq|psubq|pmuludq|pshufhw|pshuflw|pshufd|pslldq|psrldq|punpckhqdq|punpcklqdq)\\b",
				"captures": {
				"1": { "name": "support.function.sse2" }
				},
				"comment": "Function SSE2 case insensitive"
			},
			{
				"name": "support.function.sse3",
				"match": "\\b(?i:addsubpd|addsubps|haddpd|haddps|hsubpd|hsubps|movddup|movshdup|movsldup|psignw|psignd|psignb|pshufb|pmulhrsw|pmaddubsw|phsubw|phsubsw|phsubd|phaddw|phaddsw|phaddd|palignr|pabsw|pabsd|pabsb)\\b",
				"captures": {
				"1": { "name": "support.function.sse3" }
				},
				"comment": "Function SSE3 case insensitive"
			},
			{
				"name": "support.function.sse4",
				"match": "\\b(?i:mpsadbw|phminposuw|pmulld|pmuldq|dpps|dppd|blendps|blendpd|blendvps|blendvpd|pblendvb|pblendw|pminsb|pmaxsb|pminuw|pmaxuw|pminud|pmaxud|pminsd|pmaxsd|roundps|roundss|roundpd|roundsd|insertps|pinsrb|pinsrd|pinsrq|extractps|pextrb|pextrw|pextrd|pextrq|pmovsxbw|pmovzxbw|pmovsxbd|pmovzxbd|pmovsxbq|pmovzxbq|pmovsxwd|pmovzxwd|pmovsxwq|pmovzxwq|pmovsxdq|pmovzxdq|ptest|pcmpeqq|packusdw|movntdqa|lzcnt|popcnt|extrq|insertq|movntsd|movntss|crc32|pcmpestri|pcmpestrm|pcmpistri|pcmpistrm|pcmpgtq)\\b",
				"captures": {
				"1": { "name": "support.function.sse4" }
				},
				"comment": "Function SSE4 case insensitive"
			},
			{
				"name": "support.function.avx-fma",
				"match": "\\b(?i:vfmaddpd|vfmaddps|vfmaddsd|vfmaddss|vfmaddsubpd|vfmaddsubps|vfmsubaddpd|vfmsubaddps|vfmsubpd|vfmsubps|vfmsubsd|vfmsubss|vfnmaddpd|vfnmaddps|vfnmaddsd|vfnmaddss|vfnmsubpd|vfnmsubps|vfnmsubsd|vfnmsubss)\\b",
				"captures": {
				"1": { "name": "support.function.avx-fma" }
				},
				"comment": "Function Intel AVX FMA case insensitive"
			},
			{
				"name": "support.function.aes",
				"match": "\\b(?i:aesenc|aesenclast|aesdec|aesdeclast|aeskeygenassist|aesimc)\\b",
				"captures": {
				"1": { "name": "support.function.aes" }
				},
				"comment": "Function SSE4 case insensitive"
			}]
		},
		"numbers":
		{
			"match": "(?<!\\w)\\.?\\d(?:(?:[0-9a-zA-Z_\\.]|')|(?<=[eEpP])[+-])*",
			"captures":
			{
				"0":
				{
					"patterns": [
					{
						"begin": "(?=.)",
						"end": "$",
						"patterns": [
						{
							"match": "(\\G0[xX])([0-9a-fA-F](?:[0-9a-fA-F]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)?((?:(?<=[0-9a-fA-F])\\.|\\.(?=[0-9a-fA-F])))([0-9a-fA-F](?:[0-9a-fA-F]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)?((?<!')([pP])(\\+?)(\\-?)((?:[0-9](?:[0-9]|(?:(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)))?([lLfF](?!\\w))?$",
							"captures":
							{
								"1":
								{
									"name": "keyword.other.unit.hexadecimal.c"
								},
								"2":
								{
									"name": "constant.numeric.hexadecimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"3":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"4":
								{
									"name": "constant.numeric.hexadecimal.c"
								},
								"5":
								{
									"name": "constant.numeric.hexadecimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"6":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"8":
								{
									"name": "keyword.other.unit.exponent.hexadecimal.c"
								},
								"9":
								{
									"name": "keyword.operator.plus.exponent.hexadecimal.c"
								},
								"10":
								{
									"name": "keyword.operator.minus.exponent.hexadecimal.c"
								},
								"11":
								{
									"name": "constant.numeric.exponent.hexadecimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"12":
								{
									"name": "keyword.other.unit.suffix.floating-point.c"
								}
							}
						},
						{
							"match": "(\\G(?=[0-9.])(?!0[xXbB]))([0-9](?:[0-9]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)?((?:(?<=[0-9])\\.|\\.(?=[0-9])))([0-9](?:[0-9]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)?((?<!')([eE])(\\+?)(\\-?)((?:[0-9](?:[0-9]|(?:(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)))?([lLfF](?!\\w))?$",
							"captures":
							{
								"2":
								{
									"name": "constant.numeric.decimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"3":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"4":
								{
									"name": "constant.numeric.decimal.point.c"
								},
								"5":
								{
									"name": "constant.numeric.decimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"6":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"8":
								{
									"name": "keyword.other.unit.exponent.decimal.c"
								},
								"9":
								{
									"name": "keyword.operator.plus.exponent.decimal.c"
								},
								"10":
								{
									"name": "keyword.operator.minus.exponent.decimal.c"
								},
								"11":
								{
									"name": "constant.numeric.exponent.decimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"12":
								{
									"name": "keyword.other.unit.suffix.floating-point.c"
								}
							}
						},
						{
							"match": "(\\G0[bB])([01](?:[01]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)((?:(?:(?:(?:(?:[uU]|[uU]ll?)|[uU]LL?)|ll?[uU]?)|LL?[uU]?)|[fF])(?!\\w))?$",
							"captures":
							{
								"1":
								{
									"name": "keyword.other.unit.binary.c"
								},
								"2":
								{
									"name": "constant.numeric.binary.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"3":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"4":
								{
									"name": "keyword.other.unit.suffix.integer.c"
								}
							}
						},
						{
							"match": "(\\G0)((?:[0-7]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))+)((?:(?:(?:(?:(?:[uU]|[uU]ll?)|[uU]LL?)|ll?[uU]?)|LL?[uU]?)|[fF])(?!\\w))?$",
							"captures":
							{
								"1":
								{
									"name": "keyword.other.unit.octal.c"
								},
								"2":
								{
									"name": "constant.numeric.octal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"3":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"4":
								{
									"name": "keyword.other.unit.suffix.integer.c"
								}
							}
						},
						{
							"match": "(\\G0[xX])([0-9a-fA-F](?:[0-9a-fA-F]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)((?<!')([pP])(\\+?)(\\-?)((?:[0-9](?:[0-9]|(?:(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)))?((?:(?:(?:(?:(?:[uU]|[uU]ll?)|[uU]LL?)|ll?[uU]?)|LL?[uU]?)|[fF])(?!\\w))?$",
							"captures":
							{
								"1":
								{
									"name": "keyword.other.unit.hexadecimal.c"
								},
								"2":
								{
									"name": "constant.numeric.hexadecimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"3":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"5":
								{
									"name": "keyword.other.unit.exponent.hexadecimal.c"
								},
								"6":
								{
									"name": "keyword.operator.plus.exponent.hexadecimal.c"
								},
								"7":
								{
									"name": "keyword.operator.minus.exponent.hexadecimal.c"
								},
								"8":
								{
									"name": "constant.numeric.exponent.hexadecimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"9":
								{
									"name": "keyword.other.unit.suffix.integer.c"
								}
							}
						},
						{
							"match": "(\\G(?=[0-9.])(?!0[xXbB]))([0-9](?:[0-9]|((?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)((?<!')([eE])(\\+?)(\\-?)((?:[0-9](?:[0-9]|(?:(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])))*)))?((?:(?:(?:(?:(?:[uU]|[uU]ll?)|[uU]LL?)|ll?[uU]?)|LL?[uU]?)|[fF])(?!\\w))?$",
							"captures":
							{
								"2":
								{
									"name": "constant.numeric.decimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"3":
								{
									"name": "punctuation.separator.constant.numeric"
								},
								"5":
								{
									"name": "keyword.other.unit.exponent.decimal.c"
								},
								"6":
								{
									"name": "keyword.operator.plus.exponent.decimal.c"
								},
								"7":
								{
									"name": "keyword.operator.minus.exponent.decimal.c"
								},
								"8":
								{
									"name": "constant.numeric.exponent.decimal.c",
									"patterns": [
									{
										"match": "(?<=[0-9a-fA-F])'(?=[0-9a-fA-F])",
										"name": "punctuation.separator.constant.numeric"
									}]
								},
								"9":
								{
									"name": "keyword.other.unit.suffix.integer.c"
								}
							}
						},
						{
							"match": "([0-9]{1,1}[a-fA-F0-9]{0,})(h)",
							"captures":
							{
								"1":
								{
									"name": "constant.numeric.hexadecimal.c"
								},
								"2":
								{
									"name": "keyword.other.unit.hexadecimal.c"
								}
							}
						},
						{
							"match": "(?:(?:[0-9a-zA-Z_\\.]|')|(?<=[eEpP])[+-])+",
							"name": "invalid.illegal.constant.numeric"
						}]
					}]
				}
			}
		}
	}
}