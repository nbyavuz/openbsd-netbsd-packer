crontab -r
(crontab -l 2>/dev/null; echo '@reboot (/usr/pkg/bin/curl -s -L "http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script" -H "Metadata-Flavor: Google") | /bin/sh') | crontab -
