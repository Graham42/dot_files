# Laptop battery calibration and limits

`tlp` is more agressive on power saving than `power-profiles-daemon`, but may cause some inconvenience with shuting off power to usb or peripherals. On Linux Mint 22, `power-profiles-daemon` is installed by default.

## Lenovo T480s

```sh
# find the BAT0 or BAT1 device
ls /sys/class/power_supply/
# see the list of control files, etc
ls /sys/class/power_supply/BAT0/
# see the current charge control settings
head /sys/class/power_supply/BAT0/charge_*
```

There may be multiple files that look like they set the same threshold, for example, `charge_control_end_threshold` and `charge_stop_threshold`, these are effectively mirrors of each other.

Set the limit with

```sh
echo 90 | sudo tee /sys/class/power_supply/BAT0/charge_stop_threshold
echo 75 | sudo tee /sys/class/power_supply/BAT0/charge_start_threshold
```

Setting a limit of less than 100% can save battery life.
Setting a charge start threshold that is 5+% lower than the limit will save on battery cycles.

To recalibrate a new battery

1. Set the charge limits, `charge_start_threshold` to 0 (disabled), and `charge_stop_threshold` to 100
2. Charge to 100% and leave running for a couple hours
3. Make sure the power manage
3. Unplug and run until the laptop fully discharges and powers off
    NOTE: make sure the power management settings will not put the computer to sleep
4. Plug in and charge to 100% uninterrupted
5. Finally, reapply the charge limits
