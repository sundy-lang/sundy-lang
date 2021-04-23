class Sundy
  def self.lexer_rules
    {
      /\A##[^\n]*\z/                    => :DOC,
      /\A#[^\n]*\z/                     => :COMMENT,
      /\A'([^']|\\')*[']?\z/            => :STRING,
      /\A"([^"]|\\")*["]?\z/            => :STRING,
      /\A`([^`]|\\`)*[`]?\z/            => :ACTIVE_STRING,
      /\Astring\(([^)]|\\\))*[)]?\z/i   => :STRING,
      /\A\/([^\/]|\\\/)*[\/]?\z/        => :REGEXP,
      /\A@[a-z0-9_]*\z/i                => :SYMBOL,
      /\A[a-z_][a-z0-9_]*[?]?\z/i       => :ID,
      /\A[-]?[0-9_]+.[0-9_]+\z/         => :FLOAT,
      /\A[-]?[0-9_]+\z/                 => :INTEGER,
      /\A0x[0-9a-f_]+\z/i               => :HEX,
      /\A0o[0-7_]+\z/                   => :OCT,
      /\A0b[01]+\z/                     => :BIN,
      /\A[;\r\n]+\z/                    => :EOL,
      /\A[ \t]+\z/                      => :WORD_BREAK,
      '...'                             => :DOT3,
      '..'                              => :DOT2,
      '.'                               => :DOT,
      ':'                               => :DEFINE,
      ','                               => :COMMA,
      '('                               => :CHILD_BEGIN,
      ')'                               => :CHILD_END,
      '['                               => :LIST_BEGIN,
      ']'                               => :LIST_END,
      '{'                               => :BLOCK_BEGIN,
      '}'                               => :BLOCK_END,
    }
  end # self.lexer_rules
  
  def self.reserved_identifiers
    [ 'DO', 'END', 'RETURN', 'THIS', 'VAR' ]
  end # self.reserved_identifiers
  
  def self.parser_rules
    {
      [ :EOL ] => nil,
    
      [ :WORDBREAK ] => nil,
    
      [
        { type: :ID, var: :ID }, 
        { type: :WORD_BREAK, count: '*' },
        :DEFINE, 
        { type: :WORD_BREAK, count: '*' },
        :EOL,
      ] => :BEGIN_NAMESPACE_DEFINITION,
    
      [
        :END,
        { type: :WORD_BREAK, count: '+' },
        { type: :ID, var: :ID },
        { type: :WORD_BREAK, count: '*' },
        :EOL,
      ] => :END_BY_ID,
    }
  end # self.parser_rules
end # Sundy