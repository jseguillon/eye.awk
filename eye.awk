# Usage: run `echo | gawk -v usage=1 -f eye.awk`

function initLineLevelRegex() {
  d4="[0-9][0-9][0-9][0-9]" # "[0-9]{4}" expand is not "nawk" compatible

  # json, klog and others miscs, separated by special "x" character
  addLineRegex(3,"\"level\":\"debug\"")
  addLineRegex(2, "\"level\":\"info\"" x "[^ ]?I"d4 x "\\[INFO\\]")
  addLineRegex(1,"\"level\":\"warning\"" x "\"level\":\"warn\"" x "[^ ]?W"d4 x "\\[WARNING\\]")
  addLineRegex(0,"\"level\":\"error\"" x  "[^ ]?E"d4 x "\\[ERROR\\]")
  # dockerd and others text
  addLineRegex(3, "level=debug "); addLineRegex(2, "level=info ");
  addLineRegex(1, "level=warning "); addLineRegex(0, "level=error ")
  # mongodb maybe other js
  addLineRegex(3, "\"s\":\"D\""); addLineRegex(2, "\"s\":\"I\"");
  addLineRegex(1, "\"s\":\"W\""); addLineRegex(0, "\"s\":\"E\"");
}
# Colors scheme ansi 256 selection according to mode
function initColorScheme() {
  if (mode ~ /cf/ ){ initLineLevelColors(x, 1 x 2 x 4 x 5) }
  else if (mode ~ /gs/ ){ initLineLevelColors(x, 254 x 250 x 244 x 242) }
  else { initLineLevelColors(x, 209 x 178 x 117 x 99) }
  emojiArray[0]="🔥 "; emojiArray[1]= "⚠️  "; emojiArray[2]="🔵 "; emojiArray[3]="📢 "
}
# Line processing
function eye() {
  # Get line color plus style regex if matched
  lineLevel = lineHighlight(bold())
  if(! toIgnore(lineLevel)) {
    emoji=""
    if (mode ~ /moji/ ) { emoji=emojiArray[lineLevel] }
    STATS[lineLevel]=STATS[lineLevel]+1
    printf("%s%s%s%s\n", emoji, lineLevelColorsArray[lineLevel], $0, reset());
  }
  else { STATS_IGNORE[lineLevel]=STATS_IGNORE[lineLevel]+1 ; }
}
# Test whole line return a color and  style on match
function lineHighlight(style) {
  foundLevel = 99; minFoundLevel=foundLevel; finalMarker=""
  for (marker in LeveLines) {
    if (marker != "" && $0 ~ marker) {
      # Keep only lower level if mutliple match
      foundLevel = LeveLines[marker];
      if (foundLevel<minFoundLevel) { minFoundLevel=foundLevel; finalMarker=marker; }
    }
  }
  # Apply style if some regex matched
  if(minFoundLevel!=99) {
    applyStyle(finalMarker, style, lineLevelColorsArray[minFoundLevel]); return minFoundLevel;
  }
}
# replace matched with style, then matched, then reset then back to line color
function applyStyle(marker, style, color){
  gsub(marker, sprintf("%s&%s%s", style, reset(), color), $0)
}
# test if level combined term should be ignored
function toIgnore(level) {
  for (i in ignoreArray){ if (ignoreArray[i] == level && $0 ~ i) { return 1 } }
  return 0
}
# internal init functions
function initLineLevelColors(separator, lineColors) {
  split(lineColors,tmpArray, separator)
  for (i in tmpArray) { lineLevelColorsArray[i-1]=getColor(tmpArray[i]) }
  lineLevelColorsArray[99]=reset()
}
function initIgnore(){
  addIgnore(0,(ignore_error)?ignore_error:ignore_errors)
  addIgnore(1,(ignore_warning)?ignore_warning:ignore_warnings)
  addIgnore(2,(ignore_info)?ignore_info:ignore_infos)
  addIgnore(3,(ignore_debug)?ignore_debug:ignore_debugs)
}
function addIgnore(level,ignore_regex) {
  if (ignore_regex) {
    split(ignore_regex, tmpArray, "\n")
    for (i in tmpArray) { ignoreArray[tmpArray[i]]=level }
  }
}
function addLineRegex(level, array){
  split(array, tmpArray, x)
  for (i in tmpArray) { if (tmpArray[i] != "") LeveLines[tmpArray[i]]=level }
}
# Colors and style helpers
function getColor(fg,bg) {
  if (fg) {col = sprintf("\033[38;5;%dm",fg);}
  if (bg) {col = col sprintf("\033[48;5;%dm",bg);}
  return col
}
function bold() { return "\033[1m" }
function underline() { return "\033[4m" }
function reset() { return "\033[0m" }
BEGIN{
  x=SUBSEP # remember special array split character as "x"
  init()
}
function init() {
  FS="\n" # process line by lined
  initColorScheme(); initLineLevelRegex(); initIgnore();
  STATS[0]=0; STATS[1]=0; STATS[2]=0; STATS[3]=0;
  STATS_IGNORE[0]=0; STATS_IGNORE[1]=0; STATS_IGNORE[2]=0; STATS_IGNORE[3]=0;
}
{ if (!usage && !showConfig) {eye(); next } else { exit } }
END {
  if (usage) {
   print "usage: awk -v ignore_[error|warning|info|debug]=regex -v mode=[cf|gs],emoji -f eye.awk myfile"
   printf "emojis: "; for (i in emojiArray) { printf("%s", i "=" emojiArray[i] " ") }
   print ""
  }
  if (stats) {
    print reset()  "\n"
    print "Level: \t\tError\t\tWarning\t\tInfo\t\tDebug"
    print "Count:\t\t" STATS[0] "\t\t" STATS[1] "\t\t" STATS[2] "\t\t" STATS[3]
    if (ignore_error || ignore_warning || ignore_info || ignore_debug) {
      print "Ignored:\t" STATS_IGNORE[0] "\t\t" STATS_IGNORE[1] "\t\t" STATS_IGNORE[2] "\t\t" STATS_IGNORE[3]
    }
  }
  if (showConfig){
    for (i in LeveLines) { print "line regex \t level: " LeveLines[i] ", \tregex: " i }
    print ""
    for (i in ignoreArray) { print "ignore regex \t level: " ignoreArray[i] ", \tregex: " i }
   }
}
