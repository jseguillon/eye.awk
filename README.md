# eye.awk

Tiny awk script to improve kubernetes logs reading experience.

Best when:
* live tailing
* reporting in CI

Featuring :
* colours and higlights, colorblind-friendly palette
* skip and stats
* no dep but any awk, install with no root
* easy to customize

# Usage

```
# from file
awk -f eye.awk file.log

# from pipe
kubectl logs -f -n kube-system calico-node-xx |awk -f eye.awk
```

More info about usage:
```
echo |awk  -v usage=1
```

# Install

Install the way you want, in any directory you want.

Probably diserves to be aliased:
```
alias awkeye='awk -f [PATH_OF_FILE]/eye.awk '
```


## curl

```
# TODO curl
```

## Heredoc paste

Copy bellow snippet first line, press Enter, paste source script, press Enter, type `EOF` and Enter again. That's it file is now created.

```
cat <<EOF > eye.awk
..... copy here source file .....
EOF

```

Alternatively you can copy paste in preffered ediotr if available.

# Piping to less

Please use with only with uppercase `-R` flag.
```
less -R
```

Do not use minor case `-r` or you'll strange display.

# Options

## Modes

Available rendering modes:
* `-v mode=emoji`: add by level emoji at beginning of line
* `-v mode=gs`: use grayscale palette
* `-v mode=rgb`: use red-green-blue palette


Emoji mode can be combined with one palette mode:
```
awk -f eye.awk -v mode=emoji,gs file.log
```

## Per level ignoring

`-v ignore_error`, `-v ignore_warning`, `-v ignore_info`, `-v ignore_debug`


```
TODO -v ignore_x
```

## Stats

Show stats about processed lines:

```
TODO -v stats=1
```


## showConfig

```
TODO echo |awk  -v showConfig=1 -f eye.awk demo.log | sort
```
