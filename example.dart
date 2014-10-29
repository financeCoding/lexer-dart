import 'lib/lexer.dart';

/**
 * Create and run a lexer for shell command lines. Then print out lexed tokens.
 */
int main() {
  CommandLineAutomaton am = new CommandLineAutomaton();
  TokenList tokens = am.run('ls -la *.c | cat -e > out.txt && cat out.txt');
  print(tokens);
  return 0;
}

/**
 * A lexer for strings.
 *
 * Valid strings are things like `hello-world` or `file-pattern-*.dart`.
 */
class StringAutomaton extends Automaton {
  int finalState = 1;

  void lex() {
    findRegExp(0, 1, new RegExp(r'^([a-zA-Z-.*]+)'));
  }
}

/**
 * A lexer for shell command lines.
 *
 * Valid tokens are operators, strings or the end of input. This automaton
 * is recursive (see below), which allows it to match as many tokens as needed.
 */
class CommandLineAutomaton extends Automaton {
  int finalState = 2;

  void lex() {
    findWhitespace(0, 1);
    findEnd(0, 2);
    findStrings(0, 1, ['||', '&&', ';', '|', '&', '>>', '<<', '>', '<']);
    findAutomaton(0, 1, () => new StringAutomaton());
    findAutomaton(1, 2, () => new CommandLineAutomaton());
    findEnd(1, 2);
  }
}
