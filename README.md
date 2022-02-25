# eye.awk

Tiny awk script to improve kubernetes logs reading experience.

Best for:
* live tailing
* printing logs in CI

Features:
* colours and higlights, colorblind-friendly palette is default
* emojis 🔔
* stats and filters
* install with no dependencies
* easy to customize

# Usage

```
# from file
awk -f eye.awk file.log

# from pipe
kubectl logs -f -n kube-system calico-node-xx |eye.awk

# also works with kubetail, docker logs, journalctl -u containerd -u kubelet, ...

# if piping to less: use uppercase '-R' option for correct display
cat file.log |eye.awk |less -R

# if piping from kubetail, use '-k pod' option for best display
kubetail -k pod -n kube-system |eye.awk

# More info about usage:
echo |eye.awk
```

# Install

## Requirements

Nothing but a shell with any flavour of awk.

## Install via curl

Choose a target directory, dowload and set alias:
```shell
curl https://raw.githubusercontent.com/jseguillon/eye.awk/main/eye.awk -O /my_install_path/eye.awk
alias eye.awk='awk -f /my_install_path/eye.awk '
```

## Install vai Heredoc paste

Choose target directory, copy snippet first line, press Enter, paste source script, press Enter, type `EOF` and Enter again, and finally alias:
```shell
cat <<'EOF' > /my_install_path/eye.awk
..... copy here source file .....
EOF
alias eye.awk='awk -f /my_install_path/eye.awk '
```

Alternatively you can copy paste in preffered editor if available.

# Options

## Modes

Available rendering modes:
* `-v mode=emoji`: add by level emoji at beginning of line
* `-v mode=gs`: use grayscale palette
* `-v mode=ryb`: use red-yellow-blue palette
* `-v mode=stats`: show stats
* `-v mode=showConfig`: show current regex config

Modes can be combined. Example:
```
eye.awk -v mode=emoji,gs,stats file.log
```

Palette modes are exclusive.

## Per level ignoring

You can ignore some lines of logs using: `-v ignore_error`, `-v ignore_warning`, `-v ignore_info` and `-v ignore_debug`. Examples:
```shell
# skip info logs about 200 OK probes
kubetail -n my_namespace |eye.awk -v ignore_info='"statusCode":200.*"url":"/api/ping'

# skip spam error message
kubetail -n my_namespace |eye.awk -v ignore_error='myapp.*unable to get metrics.*'
```

# License

MIT

Plus: If this tool is widely adopted, I promise I won't complain I do not make money with it 😄
