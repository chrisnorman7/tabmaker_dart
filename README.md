# TabMaker

This little script turns tabs that I can understand into markdown.

## Creating Tabs

To create a tab, place the chord name inside brackets before the word (or part of the word) which should sound that chord.

### Example

See this example, taken from the included `faithful.in` file:

```tab
[G]O come, all ye [Am]faith[D]ful,
[G]Joy[D]ful [G]and [C]tri[G]um[D]phant
O [Em]come [D]ye, o [Bm]come [F#m]ye to [D]B[A7]ethle[D]hem

O [Bm]come [Am]and [G]be[Am]hold [G]Him, [D]born the [Em]King of [D]Angels
O [G]come, let us adore Him
[G]O come, let us adore Him
[G]O [C]come, [G]let [D]us [Em]a[Bm]dore [C]Him
[G]Chr[D]ist the [G]Lord
```

### Result

Converting this tab with the command `tabmaker -i faithful.in  -t "O Come, All Ye Faithful" -a "Pentatonix"` gives:

```shell
G              Am   D
O come, all ye faithful,


G  D   G   C  G D
Joyful and triumphant


  Em   D     Bm   F#m   D   A7   D
O come ye, o come ye to B...ethlehem


  Bm   Am  G Am   G    D        Em      D
O come and behold Him, born the King of Angels


  G
O come, let us adore Him


G
O come, let us adore Him


G C     G   D  Em  Bm   C
O come, let us a...dore Him


G  D       G
Christ the Lord
```

### Extras

The key of the song can be provided with the `--key` (`-k`) option, or inferred from the provided tab.

For what other things can be configured, see `tabmaker -h`.
