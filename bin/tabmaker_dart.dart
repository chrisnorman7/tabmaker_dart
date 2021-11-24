// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';

/// Return a position as a string.
String positionToString(int lineNumber, int charNumber) =>
    'line ${lineNumber + 1} char ${charNumber + 1}';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('language',
        abbr: 'l',
        help: 'The name of the language to use in the resulting code block',
        defaultsTo: 'lyrics')
    ..addOption('pad-heading',
        abbr: 'p',
        defaultsTo: '',
        help: 'The characters to prefix heading hash symbols with')
    ..addOption('title',
        abbr: 't', help: 'The title of the song', defaultsTo: 'Untitled Song')
    ..addOption('artist',
        abbr: 'a', help: 'The artist of the song', defaultsTo: 'Unknown Artist')
    ..addOption('key',
        abbr: 'k',
        help: 'The key of the song (defaults to the first discovered chord)')
    ..addOption('separator',
        abbr: 's',
        help: 'The separator character when more space is needed',
        defaultsTo: '...')
    ..addOption('chord-start',
        defaultsTo: '[',
        help: 'The character which denotes the start of a chord')
    ..addOption('chord-end',
        defaultsTo: ']', help: 'The character which denotes the end of a chord')
    ..addOption('space', defaultsTo: ' ', help: 'Whitespace character')
    ..addFlag('help', abbr: 'h', help: 'Show usage');
  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    return print(e.message);
  }
  if (results.wasParsed('help')) {
    final usage = parser.usage;
    return print('Convert easy-to-write tabs into markdown.\n\n'
        'Usage: tabmaker <in-file>[ <out-file>]'
        '\n\n$usage');
  }
  final rest = results.rest;
  if (rest.isEmpty) {
    return print('You must provide a file to read from.');
  }
  final inputFile = File(rest.first);
  if (inputFile.existsSync() == false) {
    return print('Input file ${inputFile.path} does not exist.');
  }
  final input = inputFile.readAsStringSync();
  final File? outputFile;
  if (rest.length == 2) {
    outputFile = File(rest.last);
  } else {
    outputFile = null;
    if (rest.length > 2) {
      return print('Too many arguments.');
    }
  }
  final lines = input.split('\n');
  final padHeading = results['pad-heading'] as String;
  final title = results['title'] as String;
  final artist = results['artist'] as String;
  var key = results['key'] as String?;
  final chordStart = results['chord-start'] as String;
  final chordEnd = results['chord-end'] as String;
  final space = results['space'] as String;
  final separator = results['separator'] as String;
  final score = StringBuffer();
  for (var lineNumber = 0; lineNumber < lines.length; lineNumber++) {
    final line = lines[lineNumber];
    if (line.trim().isEmpty) {
      continue;
    }
    final chord = StringBuffer();
    final chords = StringBuffer();
    final words = StringBuffer();
    bool bracketFound = false;
    int chordOverflow = 0;
    bool firstChordFound = false;
    int numberOfSpaces = 0;
    for (var charNumber = 0; charNumber < line.length; charNumber++) {
      final char = line[charNumber];
      if (char == chordStart) {
        chord.clear();
        if (bracketFound) {
          return print('Found duplicate chord start at '
              '${positionToString(lineNumber, charNumber)}.');
        }
        bracketFound = true;
      } else if (char == chordEnd) {
        firstChordFound = true;
        if (bracketFound == false) {
          return print('Unmatched chord end symbol found at '
              '${positionToString(lineNumber, charNumber)}.');
        } else if (chord.isEmpty) {
          return print('Empty chord marker at '
              '${positionToString(lineNumber, charNumber)}.');
        }
        bracketFound = false;
        numberOfSpaces = 0;
        key ??= chord.toString();
      } else {
        if (bracketFound) {
          if (numberOfSpaces == 0 && charNumber > 1 && firstChordFound) {
            words.write(separator);
            chords.write(space * (separator.length - chordOverflow));
            chordOverflow = 0;
            numberOfSpaces += separator.length;
          }
          chord.write(char);
          chords.write(char);
          chordOverflow++;
        } else {
          if (chordOverflow > 0) {
            chordOverflow--;
          } else {
            chords.write(space);
            numberOfSpaces++;
          }
          words.write(char);
        }
      }
    }
    final chordsString = chords.toString().trimRight();
    score.writeln();
    if (chordsString.isNotEmpty) {
      score.writeln(chordsString);
    }
    if (bracketFound) {
      return print('Unfinished chord at '
          '${positionToString(lineNumber, line.length)}.');
    }
    score.writeln(words);
  }
  final output = StringBuffer()
    ..writeln('$padHeading# $title')
    ..writeln()
    ..writeln('$padHeading## $artist')
    ..writeln()
    ..writeln('Key: $key')
    ..writeln()
    ..write('```${results["language"]}')
    ..write(score)
    ..writeln('```');
  if (outputFile == null) {
    stdout.write(output);
  } else {
    outputFile.writeAsStringSync(output.toString());
    print('${inputFile.path} -> ${outputFile.path}.');
  }
}
