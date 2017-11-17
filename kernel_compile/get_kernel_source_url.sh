#!/bin/bash
# All this script has to do is 'echo' the URL of the kernel source
# which may be a URL to a tar.gz or tar.xz file

# If you want to use a specific commit - e.g. linux-next-20170518 snapshot
# that we were using earlier:
# https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/snapshot/linux-next-db55616926f9e4826d266795f17512c77fe1bc8c.tar.gz

# If you want to use a stable kernel release, you can use the URL
# for the stable kernel tar.xz file (from kernel.org) - e.g. for 4.13:
# https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.13.tar.xz

# For stable kernel, you can ALSO use the snapshot URL - e.g. for 4.13:
# echo "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-4.13.tar.gz"

# Note that for stable kernels, the url on kernel.org, that goes to
# cdn.kernel.org may be faster TO DOWNLOAD (because of CDN)

# 4.13.9 stable kernel from cdn.kernel.org
echo "http://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.13.13.tar.xz"
