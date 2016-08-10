-- SML lexer.

local l = require('lexer')
local token, word_match = l.token, l.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local M = {_NAME = 'sml'}

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

local keywords = token(l.KEYWORD, word_match{
	"abstype", "and", "andalso", "as", "case", "datatype", "do", "else", "end",
	"exception", "fn", "fun", "handle", "if", "in", "infix", "infixr", "let",
	"local", "nonfix", "of", "op", "open", "orelse", "raise", "rec", "then",
	"type", "val", "with", "withtype", "while", "eqtype", "functor", "include",
	"sharing", "sig", "signature", "struct", "structure", "where", ":>"
})

local operators = token(l.OPERATOR, S('()[]{},:;._|=>-#'))

local integerConstant = l.digit * (P('_')^0 * l.digit)^0
local hexIntegerConstant = P('0x') * l.xdigit * (P('_')^0 * l.xdigit)^0
local wordConstant = P('0w') * l.digit * (P('_')^0 * l.digit)^0
local hexWordConstant = P('0wx') * l.xdigit * (P('_')^0 * l.xdigit)^0
local binWordConstant = P('0wb') * S('01') * (P('_')^0 * S('01'))^0
local realConstant = integerConstant * P('.') * integerConstant * (S('Ee') * integerConstant)^-1
local number = token(l.NUMBER, hexIntegerConstant
		+ wordConstant + hexWordConstant + binWordConstant + realConstant + integerConstant)

local singleLineComment = P('(*)') * l.nonnewline_esc^0
local blockComment = l.nested_pair('(*', '*)')
local comment = token(l.COMMENT, singleLineComment + blockComment)

local alphanumIdentifier = ('`' + l.alpha) * (S('`_') + l.alnum)^0
local symbolicIdentifier = S('!%&$#+-/:<=>?@\\~`^|*')
local identifier = token(l.IDENTIFIER, l.word + symbolicIdentifier)

M._rules = {
  {'whitespace', ws},
  {'comment', comment},
  {'number', number},
  {'keyword', keywords},
  {'operator', operators},
  {'identifier', identifier}
}

M._tokenstyles = {

}

return M
