# usage: awk -v skip_[error|warning|info|debug]=regex -v mode=[cf|gs],emoji -f eye.awk myfile

# Define per level regex, use 'x' as separator
function initLineLevelRegex() {
  d4="[0-9][0-9][0-9][0-9]" # "[0-9]{4}" expand is not "nawk" compatible

  # json, klog and others miscs
  addLineRegex(3,"\"level\":\"debug\"")
  addLineRegex(2, "\"level\":\"info\"" x "[^ ]?I"d4 x "\\[INFO\\]")
  addLineRegex(1,"\"level\":\"warning\"" x "\"level\":\"warn\"" x "[^ ]?W"d4 x "\\[WARNING\\]")
  addLineRegex(0,"\"level\":\"error\"" x  "[^ ]?E"d4 x "\\[ERROR\\]")
  # dockerd and others text
  addLineRegex(3, "level=debug "); addLineRegex(2, "level=info ");
  addLineRegex(1, "level=warning "); addLineRegex(0, "level=error ")
}
# Colors scheme ansi 256 selection according to mode
function initColorScheme() {
  if (mode ~ /cf/ ){ initLineLevelColors(x, 1 x 2 x 4 x 5) }
  else if (mode ~ /gs/ ){ initLineLevelColors(x, 254 x 250 x 244 x 242) }
  else { initLineLevelColors(x, 209 x 178 x 117 x 99) }
}
# Line processing
function eye() {
  # Get line color plus style regex if matched
  lineLevel = lineHighlight(bold())
  if(! toSkip(lineLevel)) {
    emoji=""
    if (mode ~ /moji/ ) { emoji=emojiArray[lineLevel] }
    STATS[lineLevel]=STATS[lineLevel]+1
    printf("%s%s%s%s\n", emoji, lineLevelColorsArray[lineLevel], $0, reset());
  }
  else { STATS_SKIP[lineLevel]=STATS_SKIP[lineLevel]+1 }
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
# test if level plus term should be skipped
function toSkip(level) {
  return skipArray[level] != "" && $0 ~ skipArray[level]
}
# internal init functions
function initLineLevelColors(separator, lineColors) {
  split(lineColors,tmpArray, separator)
  for (i in tmpArray) { lineLevelColorsArray[i-1]=getColor(tmpArray[i]) }
  lineLevelColorsArray[99]=reset()
}
function initSkip(){
  if(skip_error){ skipArray[0]=skip_error }
  if (skip_warning) { skipArray[1]=skip_warning }
  if (skip_info) { skipArray[2]=skip_info }
  if (skip_debug) { skipArray[3]=skip_debug }
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
  initColorScheme(); initLineLevelRegex(); initSkip();
  STATS[0]=0; STATS[1]=0; STATS[2]=0; STATS[3]=0;
  STATS_SKIP[0]=0; STATS_SKIP[1]=0; STATS_SKIP[2]=0; STATS_SKIP[3]=0;
  emojiArray[0]="🔥 "; emojiArray[1]= "⚠️  "; emojiArray[2]="🔵 "; emojiArray[3]="📢 "
}
{ eye(); next }
END {
  print reset() "\n" "Level: \t\tError\t\tWarning\t\tInfo\t\tDebug"
  print "Count:\t\t" STATS[0] "\t\t" STATS[1] "\t\t" STATS[2] "\t\t" STATS[3]
  if (skip_error || skip_warning || skip_info || skip_debug) {
    print "Skipped:\t" STATS_SKIP[0] "\t\t" STATS_SKIP[1] "\t\t" STATS_SKIP[2] "\t\t" STATS_SKIP[3]
  }
}
