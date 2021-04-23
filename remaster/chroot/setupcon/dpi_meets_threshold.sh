#!/bin/bash

function find_python() {
    for p in python3 python python2
    do
        x=$(command -v $p) || continue
        echo $x
        return 0
    done
    return 1
}

function check_threshold() {
    PYTHON_CODE='
# Works in PY2/PY3
import sys
import os


SYS_DRM_DIR = "/sys/class/drm"


def dimensions_from_edid_file(f):
    # f->str: path to edid file
    # Returns-->(h_cm-->int, v_cm-->int)
    try:
        contents = bytearray(open(f, "rb").read())
        return (contents[21], contents[22])
    except:
        return (None, None)


def connected_monitor_dirs():
    # Returns-->list of str: paths
    ret = []
    for d in os.listdir(SYS_DRM_DIR):
        p = os.path.join(SYS_DRM_DIR, d)
        if not os.path.isdir(p):
            continue
        status_file = os.path.join(p, "status")
        if not os.path.exists(status_file):
            continue
        try:
            x = open(status_file, "rb").read()
            if x != b"connected\n":
                continue
            ret.append(p)
        except:
            continue
    return ret


def monitor_get_first_mode(p):
    # p-->str: monitor path under SYS_DRM_DIR
    # Returns: (hres-->int, vres-->int)
    try:
        modes_path = os.path.join(p, "modes")
        first_mode = open(modes_path, "r").read().splitlines()[0]
        first_mode = first_mode.rstrip()
        (hres, vres) = first_mode.split("x", 1)
        (hres, vres) = (int(hres), int(vres))
        return (hres, vres)
    except:
        return (None, None)


def get_lowest_dpi():
    # Returns-->int
    ret = None
    l = connected_monitor_dirs()
    for m in l:
        edid_path = os.path.join(m, "edid")
        if os.path.exists(edid_path):
            (h_cm, v_cm) = dimensions_from_edid_file(edid_path)
            (hres, vres) = monitor_get_first_mode(m)
            if hres is None or vres is None or h_cm is None or v_cm is None:
                continue
            h_dpi = float(hres) * 2.54 / float(h_cm)
            v_dpi = float(vres) * 2.54 / float(v_cm)
            avg_dpi = (h_dpi + v_dpi) / 2.0
            if ret is None:
                ret = int(avg_dpi)
            else:
                if avg_dpi < ret:
                    ret = int(avg_dpi)
            fmt = ("DEBUG : %-32s : H=%3d cm : V=%rd cm  %d x %d"
                   " HDPI=%7.2f VDPI=%7.2f ADPI=%7.2f\n")
            sys.stderr.write(fmt % (
                os.path.basename(m),
                h_cm, v_cm,
                hres, vres,
                h_dpi, v_dpi,
                avg_dpi,
            ))
    return ret


def needs_large_font(threshold):
    # threshold-->int
    try:
        return get_lowest_dpi() > int(threshold)
    except:
        return False


if __name__ == "__main__":
    try:
        threshold = int(sys.argv[1])
        needs_large_font(threshold=threshold) or sys.exit(1)
    except:
        sys.exit(1)
'
    local PYTHON_CMD=$(find_python) || return 1
    $PYTHON_CMD -c "$PYTHON_CODE" $@
}


check_threshold $@ && {
    [[ -f /etc/default/console-setup.default ]] && \
    [[ -f /etc/default/console-setup.large ]] && {
        \cp -f /etc/default/console-setup.default /etc/default/console-setup
        cat /etc/default/console-setup.large >> /etc/default/console-setup
    }
} || true
